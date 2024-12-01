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
    dylibs = MachO::Tools.dylibs(dylib).select do |libpath|
      libpath.start_with?(lib) || (libpath.start_with?("/") && !libpath.start_with?("/usr/lib") && !libpath.start_with?("/System/Library"))
    end
    dylibs.each do |libpath|
      basename = Pathname.new(libpath).basename
      newpath = if libpath.start_with?(lib)
        libpath.sub("#{lib}/", "@rpath/")
      else
        "@rpath/#{basename}"
      end
      MachO::Tools.change_install_name(dylib, libpath, newpath)
      cp libpath, "build/Scopy.app/Contents/Frameworks"
      fix_dylib("build/Scopy.app/Contents/Frameworks/#{basename}")
    end
    MachO::Tools.add_rpath(dylib, "@executable_path/../Frameworks")
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
      "-DQWT_LIBRARIES=#{lib}/libqwt.dylib",
      "-DCMAKE_PREFIX_PATH=#{prefix}:#{lib}/cmake:#{lib}/pkgconfig:#{lib}/cmake/iio:#{lib}/cmake/gnuradio",
      "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"

    mkdir "build/Scopy.app/Contents/Frameworks"
    cp "build/iio-emu/iio-emu", "build/Scopy.app/Contents/MacOS/iio-emu"

    # Manually rename libqwt before running dylibbundler
    # because it defaults to linking without a dirname
    libqwt_names = MachO::Tools.dylibs("build/Scopy.app/Contents/MacOS/Scopy").select do |lib|
      lib.include?("libqwt") && Pathname.new(lib).relative?
    end
    libqwt_names.each do |libpath|
      newpath = "#{lib}/#{libpath}"
      MachO::Tools.change_install_name("build/Scopy.app/Contents/MacOS/Scopy", libpath, newpath)
    end

    system "yes | dylibbundler -of -b -x build/Scopy.app/Contents/MacOS/Scopy -d build/Scopy.app/Contents/Frameworks/ -p @executable_path/../Frameworks/ -s #{lib}"
    system "yes | dylibbundler -of -b -x build/Scopy.app/Contents/MacOS/iio-emu -d build/Scopy.app/Contents/Frameworks/ -p @executable_path/../Frameworks/ -s #{lib}"
    # fix_dylib("build/Scopy.app/Contents/MacOS/Scopy")

    # https://gist.github.com/akostadinov/fc688feba7669a4eb784: copy and dereference
    pycurrentversion = Pathname.new("#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions").children.select do |path|
      path.basename != Pathname.new("Current")
    end.max.basename.to_s
    pydst = "build/Scopy.app/Contents/Frameworks/Python.framework"
    mkdir_p "#{pydst}/Versions"
    cp_r "#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/#{pycurrentversion}", "#{pydst}/Versions/#{pycurrentversion}"
    ln_s pycurrentversion.to_s, "#{pydst}/Versions/Current"
    ln_s "Versions/Current/Python", "#{pydst}/Python"
    ln_s "Versions/Current/Resources", "#{pydst}/Resources"
    ln_s "Versions/Current/Headers", "#{pydst}/Headers"

    cp_r "#{lib}/iio.Framework", "build/Scopy.app/Contents/Frameworks"
    cp_r "deps/libad9361-iio/build/ad9361.framework", "build/Scopy.app/Contents/Frameworks"
    #fix_dylib("build/Scopy.app/Contents/Frameworks/iio.framework/iio")
    system "yes | dylibbundler -of -b -x build/Scopy.app/Contents/Frameworks/iio.framework/iio -d build/Scopy.app/Contents/Frameworks/ -p @executable_path/../Frameworks/ -s #{lib}"
    #fix_dylib("build/Scopy.app/Contents/Frameworks/ad9361.framework/ad9361")
    system "yes | dylibbundler -of -b -x build/Scopy.app/Contents/Frameworks/ad9361.framework/ad9361 -d build/Scopy.app/Contents/Frameworks/ -p @executable_path/../Frameworks/ -s #{lib}"

    MachO::Tools.add_rpath("build/Scopy.app/Contents/Frameworks/iio.framework/iio", "@executable_path/../Frameworks")
    MachO::Tools.add_rpath("build/Scopy.app/Contents/Frameworks/ad9361.framework/ad9361",
      "@executable_path/../Frameworks")
    MachO::Tools.add_rpath("build/Scopy.app/Contents/MacOS/Scopy", "@executable_path/../Frameworks")
    MachO::Tools.add_rpath("build/Scopy.app/Contents/MacOS/iio-emu", "@executable_path/../Frameworks")
    Dir.glob("build/Scopy.app/Contents/Frameworks/libgnuradio-iio*").each do |file|
      MachO::Tools.add_rpath(file, "@executable_path/../Frameworks/iio.framework")
      MachO::Tools.add_rpath(file, "@executable_path/../Frameworks/ad9361.framework")
    end
    system "macdeployqt", "build/Scopy.app"

    # Code signing
    Dir.glob("build/Scopy.app/Contents/**/*.dylib").each do |file|
      system "codesign", "--force", "-s", "-", file
    end
    system "codesign", "--force", "-s", "-", "build/Scopy.app/Contents/MacOS/Scopy"
    system "codesign", "--force", "-s", "-", "build/Scopy.app/Contents/MacOS/iio-emu"

    prefix.install "build/Scopy.app"
  end

  test do
    system "false"
  end
end
