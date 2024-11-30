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
  depends_on "dylibbundler" => :build
  depends_on "gnu-sed" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => :build
  depends_on "wget" => :build
  depends_on "boost"
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

  # https://gist.github.com/akostadinov/05c2a976dc16ffee9cac
  def find_follow(*paths)
    block_given? || (return enum_for(__method__, *paths))

    link_cache = {}
    link_resolve = lambda { |path|
      # puts "++ link_resolve: #{path}" # trace
      if link_cache[path]
        link_cache[path]
      else
        link_cache[path] = Pathname.new(path).realpath.to_s
      end
    }
    # this lambda should cleanup `link_cache` from unnecessary entries
    link_cache_reset = lambda { |path|
      # puts "++ link_cache_reset: #{path}" # trace
      # puts link_cache.to_s # trace
      link_cache.select! do |k, _v|
        path == k || k == "/" || path.start_with?(k + "/")
      end
      # puts link_cache.to_s # trace
    }
    link_is_recursive = lambda { |path|
      # puts "++ link_is_recursive: #{path}" # trace
      # the ckeck is useless if path is not a link but not our responsibility

      # we need to check full path for link cycles
      pn_initial = Pathname.new(path)
      unless pn_initial.absolute?
        # can we use `expand_path` here? Any issues with links?
        pn_initial = Pathname.new(File.join(Dir.pwd, path))
      end

      # clear unnecessary cache
      link_cache_reset.call(pn_initial.to_s)

      link_dst = link_resolve.call(pn_initial.to_s)

      pn_initial.ascend do |pn|
        return { link: path, dst: pn } if pn != pn_initial && link_dst == link_resolve.call(pn.to_s)
      end

      false
    }

    do_find = proc { |path|
      Find.find(path) do |path|
        if File.symlink?(path) && File.directory?(File.realpath(path))
          if path[-1] == "/"
            # probably hitting https://github.com/jruby/jruby/issues/1895
            yield(path.dup)
            Dir.new(path).each do |subpath|
              do_find.call(path + subpath) unless [".", ".."].include?(subpath)
            end
          elsif (is_recursive = link_is_recursive.call(path))
            raise "cannot handle recursive links: #{is_recursive[:link]} => #{is_recursive[:dst]}"
          else
            do_find.call(path + "/")
          end
        else
          yield(path)
        end
      end
    }

    while (path = paths.shift)
      do_find.call(path)
    end
  end

  def run_macdeployqtfix(exc, directory)
    script_url = "https://raw.githubusercontent.com/aurelien-rainone/macdeployqtfix/master/macdeployqtfix.py"

    system "curl -L '#{script_url}' | python3 - '#{exc}' '#{directory}'"
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
    cd "deps/libiio" do
      system "cmake", "-DWITH_TESTS:BOOL=OFF", "-DWITH_DOC:BOOL=OFF", "-DHAVE_DNS_SD:BOOL=ON",
      "-DENABLE_DNS_SD:BOOL=ON", "-DWITH_MATLAB_BINDINGS:BOOL=OFF", "-DCSHARP_BINDINGS:BOOL=OFF",
      "-DPYTHON_BINDINGS:BOOL=OFF", "-DINSTALL_UDEV_RULE:BOOL=OFF", "-DWITH_SERIAL_BACKEND:BOOL=ON",
      "-DENABLE_IPV6:BOOL=OFF", "-DOSX_PACKAGE:BOOL=OFF", "-DOSX_INSTALL_FRAMEWORKSDIR:PATH=#{lib}",
      "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
    "https://github.com/analogdevicesinc/libad9361-iio.git", "deps/libad9361-iio"
    cd "deps/libad9361-iio" do
      system "cmake", "-DLIBIIO_INCLUDEDIR=#{lib}/iio.Framework/Headers",
      "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
"https://github.com/analogdevicesinc/libm2k.git", "deps/libm2k"
    cd "deps/libm2k" do
      system "cmake", "-DIIO_INCLUDE_DIRS=#{lib}/iio.Framework/Headers", "-DENABLE_PYTHON=OFF",
      "-DENABLE_CSHARP=OFF", "-DBUILD_EXAMPLES=OFF", "-DENABLE_TOOLS=OFF", "-DINSTALL_UDEV_RULES=OFF",
      "-DENABLE_LOG=OFF", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
    system "git", "clone", "--depth=1", "-b", "scopy2-maint-3.10", "--recursive",
"https://github.com/analogdevicesinc/gnuradio.git", "deps/gnuradio"
    cd "deps/gnuradio" do
      system "cmake",
      "-Dlibiio_INCLUDE_DIR=#{lib}/iio.Framework/Headers",
      "-Dlibad9361_INCLUDE_DIR=#{include}",
      "-Dlibad9361_LIBRARIES=#{lib}/libad9361-iio.dylib",
      "-DPYTHON_EXECUTABLE=#{buildpath}/deps/mako/bin/python3", "-DENABLE_DEFAULT=OFF",
      "-DENABLE_GNURADIO_RUNTIME=ON", "-DENABLE_GR_ANALOG=ON", "-DENABLE_GR_BLOCKS=ON",
      "-DENABLE_GR_FFT=ON", "-DENABLE_GR_FILTER=ON", "-DENABLE_GR_IIO=ON", "-DENABLE_POSTINSTALL=OFF",
      "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
    system "git", "clone", "--depth=1", "-b", "3.10", "--recursive",
"https://github.com/analogdevicesinc/gr-scopy.git", "deps/gr-scopy"
    cd "deps/gr-scopy" do
      system "cmake", "-DWITH_PYTHON=OFF", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
"https://github.com/analogdevicesinc/gr-m2k.git", "deps/gr-m2k"
    cd "deps/gr-m2k" do
      system "cmake", "-DENABLE_PYTHON=OFF", "-DDIGITAL=OFF", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
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
    cd "deps/libtinyiiod" do
      system "cmake", "-S", ".", "-B", "build", "-DBUILD_EXAMPLES=OFF", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
    system "git", "clone", "--depth=1", "-b", "2.1", "--recursive", "https://github.com/KDAB/KDDockWidgets.git",
"deps/KDDockWidgets"
    cd "deps/KDDockWidgets" do
      system "cmake", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
"https://github.com/analogdevicesinc/iio-emu.git", "deps/iio-emu"
    cd "deps/iio-emu" do
      system "cmake", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    # Now since many deps are in prefix, we need to tell pkg-config where to
    # look for them.
    ENV.prepend_path "PKG_CONFIG_PATH", "#{lib}/pkgconfig"

    # Make it link to qwt using absolute path so that dylibbundler can find it
    system "cmake", "-DENABLE_TESTING=OFF", "-DCMAKE_EXE_LINKER_FLAGS=-L#{lib}",
    "-DCMAKE_MODULE_LINKER_FLAGS=-L#{lib}", "-DCMAKE_SHARED_LINKER_FLAGS=-L#{lib}",
    "-DCMAKE_LIBRARY_PATH=#{lib}", "-DCMAKE_STAGING_PREFIX=#{prefix}",
    "-DQWT_LIBRARIES=#{lib}/libqwt.dylib",
    "-DCMAKE_PREFIX_PATH=#{prefix}:#{lib}/cmake:#{lib}/pkgconfig:#{lib}/cmake/iio:#{lib}/cmake/gnuradio",
    "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"

    mkdir "build/Scopy.app/Contents/Frameworks"

    # Manually install libqwt before running dylibbundler
    # because it defaults to linking with relative paths
    libqwtname = `otool -L build/Scopy.app/Contents/MacOS/Scopy | grep libqwt | cut -d " " -f 1`.strip
    cp "#{lib}/#{libqwtname}", "build/Scopy.app/Contents/Frameworks"
    MachO::Tools.change_install_name(
      "build/Scopy.app/Contents/MacOS/Scopy",
      libqwtname, "@executable_path/../Frameworks/#{libqwtname}"
    )

    system "yes | dylibbundler -od -of -b -x build/Scopy.app/Contents/MacOS/Scopy -d build/Scopy.app/Contents/Frameworks/ -p @executable_path/../Frameworks/ -s #{lib}"

    # https://gist.github.com/akostadinov/fc688feba7669a4eb784: copy and dereference
    pysrc = Pathname.new("#{HOMEBREW_PREFIX}/Frameworks/Python.framework")
    pydst = "build/Scopy.app/Contents/Frameworks/Python.framework"
    mkdir_p(pydst)
    find_follow(pysrc) do |path|
      relpath = Pathname.new(path).relative_path_from(pysrc).to_s
      dstpath = File.join(pydst, relpath)
      if File.directory?(path) || (File.symlink?(path) && File.directory?(File.realpath(path)))
        mkdir_p(dstpath)
      else
        copy_file(path, dstpath)
      end
    end
    cp_r "#{lib}/iio.Framework", "build/Scopy.app/Contents/Frameworks"
    cp_r "deps/libad9361-iio/build/ad9361.framework", "build/Scopy.app/Contents/Frameworks"
    iiorpath = `otool -D build/Scopy.app/Contents/Frameworks/iio.framework/iio | grep @rpath`.strip
    ad9361rpath = `otool -D build/Scopy.app/Contents/Frameworks/ad9361.framework/ad9361 | grep @rpath`.strip
    pythonidrpath = `otool -D build/Scopy.app/Contents/Frameworks/Python.framework/Versions/Current/Python | head -2 |  tail -1`.strip
    libusbpath = `otool -L build/Scopy.app/Contents/Frameworks/iio.framework/iio | grep libusb | cut -d " " -f 1`.strip
    libusbid = `echo "#{libusbpath}" | rev | cut -d / -f 1 | rev`.strip
    cp libusbpath, "build/Scopy.app/Contents/Frameworks"

    iioid = iiorpath.sub("@rpath/", "")
    ad9361id = ad9361rpath.sub("@rpath/", "")
    pythonid = pythonidrpath.sub(%r{/opt/homebrew/opt/[^/]*/Frameworks/}, "")

    MachO::Tools.change_dylib_id(
      "build/Scopy.app/Contents/Frameworks/iio.framework/iio",
      "@executable_path/../Frameworks/#{iioid}"
    )
    MachO::Tools.change_dylib_id(
      "build/Scopy.app/Contents/Frameworks/#{iioid}",
      "@executable_path/../Frameworks/#{iioid}"
    )
    MachO::Tools.change_dylib_id(
      "build/Scopy.app/Contents/Frameworks/ad9361.framework/ad9361",
      "@executable_path/../Frameworks/#{ad9361id}"
    )
    MachO::Tools.change_dylib_id(
      "build/Scopy.app/Contents/Frameworks/#{ad9361id}",
      "@executable_path/../Frameworks/#{ad9361id}"
    )
    MachO::Tools.change_dylib_id(
      "build/Scopy.app/Contents/Frameworks/#{pythonid}",
      "@executable_path/../Frameworks/#{pythonid}"
    )
    MachO::Tools.change_dylib_id(
      "build/Scopy.app/Contents/Frameworks/#{libusbid}",
      "@executable_path/../Frameworks/#{libusbid}"
    )

    MachO::Tools.change_install_name(
      "build/Scopy.app/Contents/MacOS/Scopy", iiorpath,
      "@executable_path/../Frameworks/#{iioid}"
    )
    MachO::Tools.change_install_name(
      "build/Scopy.app/Contents/Frameworks/#{ad9361id}", iiorpath,
      "@executable_path/../Frameworks/#{iioid}"
    )
    Dir.glob("build/Scopy.app/Contents/Frameworks/libgnuradio-iio*").each do |file|
      MachO::Tools.change_install_name(file, iiorpath, "@executable_path/../Frameworks/#{iioid}")
      # MachO::Tools.change_install_name(file, ad9361rpath, "@executable_path/../Frameworks/#{ad9361id}")
    end
    # MachO::Tools.change_install_name(
    #  "build/Scopy.app/Contents/MacOS/Scopy", ad9361rpath,
    #  "@executable_path/../Frameworks/#{ad9361id}"
    # )
    Dir.glob("build/Scopy.app/Contents/Frameworks/libsigrokdecode*").each do |file|
      MachO::Tools.change_install_name(file, pythonidrpath, "@executable_path/../Frameworks/#{pythonid}")
    end
    MachO::Tools.change_install_name(
      "build/Scopy.app/Contents/Frameworks/iio.framework/iio", libusbpath,
      "@executable_path/../Frameworks/#{libusbid}"
    )

    system "macdeployqt", "build/Scopy.app"
    run_macdeployqtfix("build/Scopy.app/Contents/MacOS/Scopy", "#{HOMEBREW_PREFIX}/opt/qt/")
    run_macdeployqtfix("build/Scopy.app/Contents/MacOS/Scopy", "build/Scopy.app/Contents/Frameworks/")

    prefix.install "build/Scopy.app"
  end

  test do
    system "false"
  end
end
