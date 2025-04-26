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

  def cmake_build_this(dir, *args)
    cd dir do
      system "cmake", *args, "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end
  end

  # Instead of using dylibbundler, we use our own script to copy and dereference
  # all the dylibs.
  def fix_dylib(dylib)
    frameworkbase = Pathname.new("build/Scopy.app/Contents/Frameworks")
    chmod "u+w", dylib
    dylibs = MachO::Tools.dylibs(dylib).select do |libpath|
      # Do not copy macOS system libraries, but always copy any Homebrew libraries
      libpath.start_with?(HOMEBREW_PREFIX) || (libpath.start_with?("/") && !libpath.start_with?("/usr/lib") && !libpath.start_with?("/System/Library"))
    end
    dylibs.each do |libpathstr|
      libpath = Pathname.new(libpathstr)
      if libpathstr.include?(".framework")
        # Find the first parent directory that ends with .framework
        frameworkpath = libpath
        frameworkpath = frameworkpath.parent until frameworkpath.basename.to_s.end_with?(".framework")
        frameworkname = frameworkpath.basename
        # Copy the framework to the destination if it doesn't exist
        dest = frameworkbase + frameworkname
        cp_r frameworkpath, frameworkbase unless dest.exist?
        # Find the relative path from the rpath to the dylib
        relative_path = frameworkname + libpath.relative_path_from(frameworkpath)
        newpath = "@executable_path/../Frameworks/#{relative_path}"
        MachO::Tools.change_install_name(dylib, libpath.to_s, newpath)
        fix_dylib(frameworkbase + relative_path)
      else
        basename = libpath.basename
        dest = frameworkbase + basename
        cp libpath, frameworkbase unless dest.exist?
        newpath = "@executable_path/../Frameworks/#{basename}"
        MachO::Tools.change_install_name(dylib, libpath.to_s, newpath)
        fix_dylib(frameworkbase + basename)
      end
    end
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
    cmake_build_this "deps/libiio", "-DWITH_TESTS:BOOL=OFF", "-DWITH_DOC:BOOL=OFF",
      "-DHAVE_DNS_SD:BOOL=ON", "-DENABLE_DNS_SD:BOOL=ON", "-DWITH_MATLAB_BINDINGS:BOOL=OFF",
      "-DCSHARP_BINDINGS:BOOL=OFF", "-DPYTHON_BINDINGS:BOOL=OFF", "-DINSTALL_UDEV_RULE:BOOL=OFF",
      "-DWITH_SERIAL_BACKEND:BOOL=ON", "-DENABLE_IPV6:BOOL=OFF", "-DOSX_PACKAGE:BOOL=OFF",
      "-DOSX_INSTALL_FRAMEWORKSDIR:PATH=#{lib}"

    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
      "https://github.com/analogdevicesinc/libad9361-iio.git", "deps/libad9361-iio"
    cmake_build_this "deps/libad9361-iio", "-DLIBIIO_INCLUDEDIR=#{lib}/iio.Framework/Headers"

    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
      "https://github.com/analogdevicesinc/libm2k.git", "deps/libm2k"
    cmake_build_this "deps/libm2k", "-DIIO_INCLUDE_DIRS=#{lib}/iio.Framework/Headers",
      "-DENABLE_PYTHON=OFF", "-DENABLE_CSHARP=OFF", "-DBUILD_EXAMPLES=OFF", "-DENABLE_TOOLS=OFF",
      "-DINSTALL_UDEV_RULES=OFF", "-DENABLE_LOG=OFF"

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
    cmake_build_this "deps/libtinyiiod", "-DBUILD_EXAMPLES=OFF"

    system "git", "clone", "--depth=1", "-b", "2.1", "--recursive", "https://github.com/KDAB/KDDockWidgets.git",
      "deps/KDDockWidgets"
    cmake_build_this "deps/KDDockWidgets"

    system "git", "clone", "--depth=1", "-b", "main", "--recursive",
      "https://github.com/analogdevicesinc/iio-emu.git", "deps/iio-emu"
    cmake_build_this "deps/iio-emu"

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

    mkdir "build/Scopy.app/Contents/Frameworks"
    cp "deps/iio-emu/build/iio-emu", "build/Scopy.app/Contents/MacOS/iio-emu"

    # Manually rename libqwt before running dylibbundler
    # because it defaults to linking without a dirname
    libqwt_names = MachO::Tools.dylibs("build/Scopy.app/Contents/MacOS/Scopy").select do |lib|
      lib.include?("libqwt") && Pathname.new(lib).relative?
    end
    libqwt_names.each do |libpath|
      newpath = "#{lib}/#{libpath}"
      MachO::Tools.change_install_name("build/Scopy.app/Contents/MacOS/Scopy", libpath, newpath)
    end

    fix_dylib("build/Scopy.app/Contents/MacOS/Scopy")
    fix_dylib("build/Scopy.app/Contents/MacOS/iio-emu")
    Dir.glob("build/Scopy.app/Contents/MacOS/plugins/*.dylib").each do |file|
      fix_dylib(file)
    end

    frameworkbase = Pathname.new("build/Scopy.app/Contents/Frameworks")

    # https://gist.github.com/akostadinov/fc688feba7669a4eb784: copy and dereference
    pycurrentversion = Pathname.new("#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions").children.reject do |path|
      path.basename == Pathname.new("Current")
    end.max.basename

    pydst = frameworkbase + "Python.framework"

    mkdir_p pydst + "Versions"
    cp_r "#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/#{pycurrentversion}",
pydst + "Versions" + pycurrentversion
    ln_s pycurrentversion, "#{pydst}/Versions/Current" unless (pydst + "Versions/Current").exist?
    ln_s "Versions/Current/Python", "#{pydst}/Python" unless (pydst + "Python").exist?
    ln_s "Versions/Current/Resources", "#{pydst}/Resources" unless (pydst + "Resources").exist?
    ln_s "Versions/Current/Headers", "#{pydst}/Headers" unless (pydst + "Headers").exist?

    cp_r "#{lib}/iio.Framework", frameworkbase unless (frameworkbase + "iio.Framework").exist?
    cp_r "deps/libad9361-iio/build/ad9361.framework", frameworkbase unless (frameworkbase + "ad9361.framework").exist?
    fix_dylib("build/Scopy.app/Contents/Frameworks/iio.framework/iio")
    fix_dylib("build/Scopy.app/Contents/Frameworks/ad9361.framework/ad9361")

    Dir.glob(frameworkbase + "libgnuradio-iio*").each do |file|
      begin
        MachO::Tools.add_rpath(file, "@executable_path/../Frameworks/iio.framework")
      rescue MachO::RpathExistsError
      end
      begin
        MachO::Tools.add_rpath(file, "@executable_path/../Frameworks/ad9361.framework")
      rescue MachO::RpathExistsError
      end
    end
    system "macdeployqt", "build/Scopy.app"

    # Code signing
    Dir.glob("build/Scopy.app/Contents/**/*.dylib").each do |file|
      system "codesign", "--force", "-s", "-", file
    end
    # Ignore error for this one
    begin
      system "codesign", "--force", "-s", "-", "build/Scopy.app/Contents/MacOS/Scopy"
    rescue
      nil
    end
    system "codesign", "--force", "-s", "-", "build/Scopy.app/Contents/MacOS/iio-emu"

    prefix.install "build/Scopy.app"
  end

  test do
    system "false"
  end
end
