require "find"
require "pathname"
require "macho"

class Scopy < Formula
  include Language::Python::Virtualenv

  desc "Multi-functional software toolset with strong capabilities for signal analysis"
  homepage "https://wiki.analog.com/university/tools/m2k/scopy"
  license "GPL-3.0-or-later"
  head "https://github.com/analogdevicesinc/scopy.git", branch: "main"
  keg_only "prefix only contains dependencies"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "bison" => :build
  depends_on "cmake" => :build
  depends_on "gnu-sed" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "boost@1.85"
  depends_on "doxygen"
  depends_on "fftw"
  depends_on "gettext"
  depends_on "glib"
  depends_on "glog"
  depends_on "libmatio"
  depends_on "libsndfile"
  depends_on "libusb"
  depends_on "libxml2"
  depends_on "libzip"
  depends_on "python3"
  depends_on "qt@5"
  depends_on "spdlog"
  depends_on "volk"
  # This is an unlisted dependency
  depends_on "webp"

  def cmake_build_this(dir, *args)
    cd dir do
      system "cmake", *args, "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
  end

  DEFAULT_WANTED_INSTALL_NAME_BASE = "@executable_path/../Frameworks".freeze

  # Instead of using dylibbundler, we use our own script to copy and dereference
  # all the dylibs.
  def copy_framework(libpath, targetdir, referring_macho, old_name, rpath_search, wanted_install_name_base)
    # Copy a framework; see `copy_macho_dep` for argument description.
    #
    # Find the first parent directory that ends with .framework
    frameworkpath = libpath
    frameworkpath = frameworkpath.parent until frameworkpath.basename.to_s.end_with?(".framework")
    # Now the basename would be the framework name, like `iio.framework`
    frameworkname = frameworkpath.basename
    # Copy the framework to the destination if it doesn't exist
    dest = targetdir + frameworkname
    cp_r frameworkpath, targetdir unless dest.exist?
    # Find the relative path of the macho, from the framework bundle root,
    # like `Versions/0.26/iio`.
    # Prepend the framework name to form the new install name
    relative_path = frameworkname + libpath.relative_path_from(frameworkpath)
    new_name = "#{wanted_install_name_base}/#{relative_path}"
    referring_macho.change_install_name(old_name, new_name)
    fix_dylib(targetdir + relative_path, targetdir, rpath_search, Pathname.new(referring_macho.filename),
              wanted_install_name_base)
  end

  def copy_single_dylib(libpath, targetdir, referring_macho, old_name, rpath_search, wanted_install_name_base)
    # Copy a single .dylib; see `copy_macho_dep` for argument description.
    basename = libpath.basename
    dest = targetdir + basename
    cp libpath, targetdir unless dest.exist?
    new_name = "#{wanted_install_name_base}/#{basename}"
    referring_macho.change_install_name(old_name, new_name)
    fix_dylib(dest, targetdir, rpath_search, Pathname.new(referring_macho.filename), wanted_install_name_base)
  end

  def copy_macho_dep(libpath, targetdir, referring_macho, old_name, rpath_search, wanted_install_name_base)
    # Copy `libpath` to `targetdir`.
    #
    # - `libpath` should be the on-disk location of `old_name`. They may be the same.
    #   If `libpath` refers to a framework, it should point to the Mach-O file inside the bundle,
    #   like `some/path/iio.framework/Versions/0.26/iio`, instead of the bundle root.
    #
    # - `targetdir` is the physical location of the `Frameworks` directory of the application bundle.
    #
    # - `referring_macho` is the original file that links to `libpath`.
    #   Its loader table (the `LC_LOAD_DYLIB` command) will be updated to point to
    #   `wanted_install_name_base`, and its path will be used to compute `@loader_path`.
    #
    # - `old_name` should be an entry in the loader table of `referring_macho`.
    #
    # - `rpath_search` is an array of `Pathname`s where we try to locate `@rpath` entries.
    #   For this function, `rpath_search` is only used to recursively call `fix_dylib`.
    #
    # - `wanted_install_name_base` is a relative reference to `targetdir`.
    #   A sane default is `DEFAULT_WANTED_INSTALL_NAME_BASE`.
    if libpath.to_s.include?(".framework")
      copy_framework(libpath, targetdir, referring_macho, old_name, rpath_search, wanted_install_name_base)
    else
      copy_single_dylib(libpath, targetdir, referring_macho, old_name, rpath_search, wanted_install_name_base)
    end
  end

  def fix_dylib(machopath, targetdir, rpath_search, loader_machopath = nil,
                wanted_install_name_base = DEFAULT_WANTED_INSTALL_NAME_BASE)
    # Copy non-system dylibs referred by `machopath` to `targetdir`, and update
    # the install names to point to the new destination via a relative path based
    # from `wanted_install_name_base`.
    #
    # The caller should ensure that `wanted_install_name_base` resolves to
    # `targetdir` in this Mach-O.
    chmod "u+w", machopath
    macho = MachO.open(machopath)

    # Precompute `loader_path` in case used
    # Find the dirname from the dirname of `macho`'s loader (containing the `.dylib` or the `.Framework`)
    if loader_machopath.nil?
      loader_path = nil
    elsif loader_machopath.to_s.include?(".framework")
      loader_path = loader_machopath
      loader_path = loader_path.parent until loader_path.basename.to_s.end_with?(".framework")
      loader_path = loader_path.parent
    else
      loader_path = loader_machopath.parent
    end

    macho.linked_dylibs.each do |libpathstr|
      # Do not copy macOS system libraries
      next if libpathstr.start_with?("/usr/lib", "/System/Library")

      if libpathstr.start_with?("/")
        # Simple logic for absolute path references (we already skipped system libraries)
        libpath = Pathname.new(libpathstr)
        copy_macho_dep(libpath, targetdir, macho, libpathstr, rpath_search, wanted_install_name_base)
      elsif libpathstr.start_with?("@rpath") || !libpathstr.start_with?("@")
        # A @rpath/.., or a relative path. We deal with them on a best-effort basis.
        lib_fromrpath = libpathstr.delete_prefix("@rpath/")

        if (targetdir + lib_fromrpath).exist?
          # This framework or dylib is already in `targetdir`
          # We just change the install name
          macho.change_install_name(libpathstr, "#{wanted_install_name_base}/#{lib_fromrpath}")
          next
        end

        found_parent = rpath_search.find do |candidate|
          (candidate + lib_fromrpath).exist?
        end
        if found_parent
          copy_macho_dep(found_parent + lib_fromrpath, targetdir, macho, libpathstr, rpath_search,
                         wanted_install_name_base)
        else
          opoo "Warning: Cannot resolve rpath #{libpathstr}"
        end
      elsif libpathstr.start_with?("@loader_path")
        if loader_path.nil?
          opoo "Warning: Not expecting a @loader_path in Mach-O #{machopath}"
          next
        end
        lib_fromlpath = libpathstr.delete_prefix("@loader_path/")
        if (targetdir + lib_fromlpath).exist?
          macho.change_install_name(libpathstr, "#{wanted_install_name_base}/#{lib_fromlpath}")
        elsif (loader_path + lib_fromlpath).exist?
          copy_macho_dep(loader_path + lib_fromlpath, targetdir, macho, libpathstr, rpath_search,
                         wanted_install_name_base)
        else
          opoo "Warning: Cannot resolve @loader_path #{libpathstr}"
        end
        # else: a @... path that we don't know how to handle. Leave it as-is
      end
    end
    # Libraries added by the Scopy build script uses @rpath; make sure they still work
    if macho.rpaths.exclude?(wanted_install_name_base) && macho.rpaths.exclude?(wanted_install_name_base + "/")
      macho.add_rpath(wanted_install_name_base)
    end
    # Don't forget to write the changes
    macho.write!
  end

  def install
    # Install Mako for volk (build dependency)
    venv = virtualenv_create("deps/mako")
    venv.pip_install ["mako", "setuptools", "markupsafe"] # setuptools is needed for markupsafe in Python 3.12
    # Based on Scopy macOS CI on Azure
    # Clone and build dependencies
    system "git", "clone", "--depth=1", "-b", "scopy-v2", "--recursive", "https://github.com/cseci/libserialport",
    "deps/libserialport"
    cd "deps/libserialport" do
      system "./autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make", "install"
    end

    system "git", "clone", "--depth=1", "-b", "v0.26", "--recursive",
      "https://github.com/analogdevicesinc/libiio.git", "deps/libiio"
    cmake_build_this "deps/libiio", "-DWITH_TESTS=OFF", "-DWITH_DOC=OFF",
      "-DHAVE_DNS_SD=ON", "-DENABLE_DNS_SD=ON", "-DWITH_MATLAB_BINDINGS=OFF",
      "-DCSHARP_BINDINGS=OFF", "-DPYTHON_BINDINGS=OFF", "-DINSTALL_UDEV_RULE=OFF",
      "-DWITH_SERIAL_BACKEND=ON", "-DENABLE_IPV6=OFF",
      "-DOSX_PACKAGE=OFF", "-DOSX_INSTALL_FRAMEWORKSDIR=#{lib}"

    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
      "https://github.com/analogdevicesinc/libad9361-iio.git", "deps/libad9361-iio"
    cmake_build_this "deps/libad9361-iio", "-DLIBIIO_INCLUDEDIR=#{lib}/iio.Framework/Headers",
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5", "-DOSX_PACKAGE=OFF", "-DOSX_FRAMEWORK=OFF"

    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
      "https://github.com/analogdevicesinc/libm2k.git", "deps/libm2k"
    cmake_build_this "deps/libm2k", "-DIIO_INCLUDE_DIRS=#{lib}/iio.Framework/Headers",
      "-DENABLE_PYTHON=OFF", "-DENABLE_CSHARP=OFF", "-DBUILD_EXAMPLES=OFF", "-DENABLE_TOOLS=OFF",
      "-DINSTALL_UDEV_RULES=OFF", "-DENABLE_LOG=OFF",
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"

    system "git", "clone", "--depth=1", "-b", "scopy2-maint-3.10", "--recursive",
      "https://github.com/analogdevicesinc/gnuradio.git", "deps/gnuradio"
    cmake_build_this "deps/gnuradio", "-Dlibiio_INCLUDE_DIR=#{lib}/iio.Framework/Headers",
      "-Dlibad9361_INCLUDE_DIR=#{include}",
      "-Dlibad9361_LIBRARIES=#{lib}/libad9361-iio.dylib",
      "-DPYTHON_EXECUTABLE=#{buildpath}/deps/mako/bin/python3", "-DENABLE_DEFAULT=OFF",
      "-DENABLE_GNURADIO_RUNTIME=ON", "-DENABLE_GR_ANALOG=ON", "-DENABLE_GR_BLOCKS=ON",
      "-DENABLE_GR_FFT=ON", "-DENABLE_GR_FILTER=ON", "-DENABLE_GR_IIO=ON", "-DENABLE_POSTINSTALL=OFF"

    system "git", "clone", "--depth=1", "-b", "3.10", "--recursive",
      "https://github.com/analogdevicesinc/gr-scopy.git", "deps/gr-scopy"
    cmake_build_this "deps/gr-scopy", "-DWITH_PYTHON=OFF"

    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
      "https://github.com/analogdevicesinc/gr-m2k.git", "deps/gr-m2k"
    cmake_build_this "deps/gr-m2k", "-DENABLE_PYTHON=OFF", "-DDIGITAL=OFF"

    system "git", "clone", "--depth=1", "-b", "qwt-multiaxes-updated", "--recursive",
      "https://github.com/cseci/qwt.git", "deps/qwt"
    cd "deps/qwt" do
      inreplace "qwtconfig.pri" do |s|
        s.gsub! "/usr/local/qwt-$$QWT_VERSION-ma", prefix.to_s
        s.gsub! "QWT_CONFIG += QwtFramework", "#QWT_CONFIG += QwtFramework"
      end
      # inreplace "src/src.pro" do |s|
      #   s.gsub! "QWT_SONAME=libqwt.so.$${VER_MAJ}.$${VER_MIN}",
      #   s.gsub! "QWT_SONAME=libqwtmathml.so.$${VER_MAJ}.$${VER_MIN}",
      # end
      system "qmake", "INCLUDEPATH=#{include}", "LIBS+=-L#{lib}", "qwt.pro"
      system "make"
      system "make", "install"
    end
    system "git", "clone", "--depth=1", "-b", "master", "--recursive",
      "https://github.com/sigrokproject/libsigrokdecode.git", "deps/libsigrokdecode"
    cd "deps/libsigrokdecode" do
      system "./autogen.sh"
      system "./configure", "--prefix=#{prefix}"
      system "make"
      system "make", "install"
    end
    system "git", "clone", "--depth=1", "-b", "master", "--recursive",
      "https://github.com/analogdevicesinc/libtinyiiod.git", "deps/libtinyiiod"
    cmake_build_this "deps/libtinyiiod", "-DBUILD_EXAMPLES=OFF", "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"

    system "git", "clone", "--depth=1", "-b", "2.1", "--recursive", "https://github.com/KDAB/KDDockWidgets.git",
      "deps/KDDockWidgets"
    cmake_build_this "deps/KDDockWidgets"

    system "git", "clone", "--depth=1", "-b", "kf5", "--recursive", "https://github.com/KDE/extra-cmake-modules.git",
      "deps/ECM"
    cmake_build_this "deps/ECM", "-DBUILD_TESTING=OFF", "-DBUILD_HTML_DOCS=OFF",
      "-DBUILD_MAN_DOCS=OFF", "-DBUILD_QTHELP_DOCS=OFF"

    system "git", "clone", "--depth=1", "-b", "kf5", "--recursive", "https://github.com/KDE/karchive.git",
      "deps/karchive"
    cmake_build_this "deps/karchive", "-DBUILD_TESTING=OFF"

    system "git", "clone", "--depth=1", "-b", "main", "--recursive", "https://github.com/analogdevicesinc/genalyzer.git",
      "deps/genalyzer"
    cmake_build_this "deps/genalyzer", "-DBUILD_TESTING=OFF", "-DBUILD_SHARED_LIBS=ON"

    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
      "https://github.com/analogdevicesinc/iio-emu.git", "deps/iio-emu"
    cmake_build_this "deps/iio-emu", "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"

    # Now since many deps are in prefix, we need to tell pkg-config where to
    # look for them.
    ENV.prepend_path "PKG_CONFIG_PATH", "#{lib}/pkgconfig"

    # Make it link to qwt using absolute path so that dylibbundler can find it
    system "cmake", "-DENABLE_TESTING=OFF", "-DCMAKE_EXE_LINKER_FLAGS=-L#{lib}",
      "-DCMAKE_MODULE_LINKER_FLAGS=-L#{lib}", "-DCMAKE_SHARED_LINKER_FLAGS=-L#{lib}",
      "-DCMAKE_LIBRARY_PATH=#{lib}", "-DCMAKE_STAGING_PREFIX=#{prefix}",
      "-DQWT_LIBRARIES=#{lib}/libqwt.dylib", "-DIIO_INCLUDE_DIRS=#{lib}/iio.Framework/Headers",
      "-DCMAKE_PREFIX_PATH=#{prefix}:#{lib}/cmake:#{lib}/pkgconfig:#{lib}/cmake/iio:#{lib}/cmake/gnuradio",
      "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"

    targetdir = Pathname.new("build/Scopy.app/Contents/Frameworks")
    mkdir_p targetdir
    cp "deps/iio-emu/build/iio-emu", "build/Scopy.app/Contents/MacOS/iio-emu"

    fix_dylib("build/Scopy.app/Contents/MacOS/Scopy", targetdir, [lib])
    fix_dylib("build/Scopy.app/Contents/MacOS/iio-emu", targetdir, [lib])
    Dir.glob("build/Scopy.app/Contents/MacOS/**/*.dylib").each do |file|
      fix_dylib(file, targetdir, [lib])
    end

    frameworkbase = Pathname.new("build/Scopy.app/Contents/Frameworks")

    # https://gist.github.com/akostadinov/fc688feba7669a4eb784: copy and dereference
    v = Pathname.new("#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions").children.reject do |path|
      path.basename == Pathname.new("Current")
    end
    pycurrentversion = v.max.basename

    pydst = frameworkbase + "Python.framework"

    mkdir_p pydst + "Versions"
    cp_r "#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/#{pycurrentversion}",
         pydst + "Versions" + pycurrentversion
    ln_s pycurrentversion, "#{pydst}/Versions/Current" unless (pydst + "Versions/Current").exist?
    ln_s "Versions/Current/Python", "#{pydst}/Python" unless (pydst + "Python").exist?
    ln_s "Versions/Current/Resources", "#{pydst}/Resources" unless (pydst + "Resources").exist?
    ln_s "Versions/Current/Headers", "#{pydst}/Headers" unless (pydst + "Headers").exist?

    cp_r "#{lib}/iio.Framework", frameworkbase unless (frameworkbase + "iio.Framework").exist?
    fix_dylib("build/Scopy.app/Contents/Frameworks/iio.framework/iio", targetdir, [lib])

    Dir.glob(frameworkbase + "libgnuradio-iio*").each do |file|
        MachO::Tools.add_rpath(file, "#{DEFAULT_WANTED_INSTALL_NAME_BASE}/iio.framework")
    rescue MachO::RpathExistsError
        nil
    end
    system "macdeployqt", "build/Scopy.app"

    # Code signing
    Find.find("build/Scopy.app/Contents") do |file|
      # Only sign regular files
      next unless File.file?(file)
      # Skip this and sign it last
      next if file == "build/Scopy.app/Contents/MacOS/Scopy"

      chmod "u+w", file
      system "codesign", "--force", "--sign", "-", file
    end
    # Finally sign this after the bundle is finished
    system "codesign", "--force", "--sign", "-", "build/Scopy.app/Contents/MacOS/Scopy"

    prefix.install "build/Scopy.app"
  end

  def caveats
    <<~EOS
      This installation script does not link the app to /Applications.

      To find Scopy in Launchpad, run
      ```
      ln -s #{opt_prefix}/Scopy.app /Application
      ```
    EOS
  end

  test do
    system "false"
  end
end
