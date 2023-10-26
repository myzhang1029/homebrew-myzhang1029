class Sdrplusplus < Formula
  include Language::Python::Virtualenv

  desc "Cross-Platform SDR Software"
  homepage "https://www.sdrpp.org"
  license "GPL-3.0-or-later"
  head "https://github.com/AlexandreRouma/SDRPlusPlus.git", branch: "master"
  keg_only "prefix only contains dependencies"
  depends_on "airspy" => :build
  depends_on "airspyhf" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmake" => :build
  depends_on "codec2" => :build
  depends_on "fftw" => :build
  depends_on "glfw" => :build
  depends_on "hackrf" => :build
  depends_on "libbladerf" => :build
  depends_on "libtool" => :build
  depends_on "libusb" => :build
  depends_on "pkg-config" => :build
  depends_on "portaudio" => :build
  depends_on "python" => :build
  depends_on "soapysdr" => :build
  depends_on "zstd" => :build

  # This patch is needed because the original `CMakeLists.txt` file
  # hardcodes a Frameworks path that we are not using.
  patch :DATA

  def install
    # Install Mako for volk (build dependency)
    virtualenv_create("deps/mako", without_pip: false)
    system "#{buildpath}/deps/mako/bin/pip", "install", "mako"
    # Install volk
    system "git", "clone", "--recursive", "--depth", "1", "https://github.com/gnuradio/volk.git", "deps/volk"
    cd "deps/volk" do
      system "cmake", "-S", ".", "-B", "build", "-DPYTHON_EXECUTABLE=#{buildpath}/deps/mako/bin/python3",
*std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    # Install SDRplay API
    # Skipping for now. We don't want random binaries in our cellar.
    #
    # Install libiio
    system "git", "clone", "--depth", "1", "--branch", "v0.25", "https://github.com/analogdevicesinc/libiio.git",
"deps/libiio"
    cd "deps/libiio" do
      system "cmake", "-S", ".", "-B", "build", "-DOSX_PACKAGE=OFF", "-DOSX_FRAMEWORK=OFF", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
      # `libad9361` expects `iio.h` to be in `include/iio` on Mac but since we
      # are not using the framework, it is in `include` instead. Let's fix that.
      mkdir_p "#{include}/iio"
      ln_s "../iio.h", "#{include}/iio/iio.h"
    end

    # Install libad9361-iio
    system "git", "clone", "--depth", "1", "https://github.com/analogdevicesinc/libad9361-iio.git",
"deps/libad9361-iio"
    cd "deps/libad9361-iio" do
      system "cmake", "-S", ".", "-B", "build", "-DOSX_PACKAGE=OFF", "-DOSX_FRAMEWORK=OFF", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    # Install LimeSuite
    system "git", "clone", "--depth", "1", "https://github.com/myriadrf/LimeSuite.git", "deps/LimeSuite"
    cd "deps/LimeSuite" do
      system "cmake", "-S", ".", "-B", "build", "-DENABLE_OCTAVE=OFF", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    # Install libperseus
    system "git", "clone", "--depth", "1", "https://github.com/Microtelecom/libperseus-sdr.git", "deps/libperseus-sdr"
    cd "deps/libperseus-sdr" do
      system "autoreconf", "-i"
      system "./configure", "--prefix=#{prefix}"
      system "make", "install"
    end

    # Install more recent librtlsdr
    system "git", "clone", "--depth", "1", "https://github.com/osmocom/rtl-sdr.git", "deps/rtl-sdr"
    cd "deps/rtl-sdr" do
      system "cmake", "-S", ".", "-B", "build", *std_cmake_args
      system "cmake", "--build", "build"
      system "cmake", "--install", "build"
    end

    # Now since many deps are in prefix, we need to tell pkg-config where to
    # look for them.
    ENV.prepend_path "PKG_CONFIG_PATH", "#{lib}/pkgconfig"

    system "cmake",
      "-S", ".",
      "-B", "build",
      "-DOPT_BUILD_PLUTOSDR_SOURCE=ON",
      "-DOPT_BUILD_SOAPY_SOURCE=ON",
      "-DOPT_BUILD_BLADERF_SOURCE=ON",
      # Since we disabled SDR Play
      "-DOPT_BUILD_SDRPLAY_SOURCE=OFF",
      "-DOPT_BUILD_LIMESDR_SOURCE=ON",
      "-DOPT_BUILD_AUDIO_SINK=OFF",
      "-DOPT_BUILD_PORTAUDIO_SINK=ON",
      "-DOPT_BUILD_NEW_PORTAUDIO_SINK=ON",
      "-DOPT_BUILD_M17_DECODER=ON",
      "-DOPT_BUILD_PERSEUS_SOURCE=ON",
      "-DOPT_BUILD_PLUTOSDR_SOURCE=ON",
      "-DOPT_BUILD_AUDIO_SOURCE=OFF",
      "-DUSE_BUNDLE_DEFAULTS=ON",
      # Let's get more decoders once they are available
      # "-DOPT_BUILD_ATV_DECODER=ON",
      # "-DOPT_BUILD_KG_SSTV_DECODER=ON",
      "-DOPT_BUILD_M17_DECODER=ON",
      # "-DOPT_BUILD_WEATHER_SAT_DECODER=ON",
      *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
    system "sh", "make_macos_bundle.sh", "build", "SDR++.app"
    prefix.install "SDR++.app"
  end

  test do
    system "false"
  end
end

__END__
diff --git a/source_modules/plutosdr_source/CMakeLists.txt b/source_modules/plutosdr_source/CMakeLists.txt
index d65187caf..8ded43feb 100644
--- a/source_modules/plutosdr_source/CMakeLists.txt
+++ b/source_modules/plutosdr_source/CMakeLists.txt
@@ -23,26 +23,18 @@ elseif (ANDROID)
         /sdr-kit/${ANDROID_ABI}/lib/libad9361.so
     )
 else (MSVC)
-    if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
-        target_include_directories(plutosdr_source PRIVATE "/Library/Frameworks/iio.framework/Headers")
-        target_link_libraries(plutosdr_source PRIVATE "/Library/Frameworks/iio.framework/iio")
+    find_package(PkgConfig)

-        target_include_directories(plutosdr_source PRIVATE "/Library/Frameworks/ad9361.framework/Headers")
-        target_link_libraries(plutosdr_source PRIVATE "/Library/Frameworks/ad9361.framework/ad9361")
-    else()
-        find_package(PkgConfig)
+    pkg_check_modules(LIBIIO REQUIRED libiio)
+    pkg_check_modules(LIBAD9361 REQUIRED libad9361)

-        pkg_check_modules(LIBIIO REQUIRED libiio)
-        pkg_check_modules(LIBAD9361 REQUIRED libad9361)
+    target_include_directories(plutosdr_source PRIVATE ${LIBIIO_INCLUDE_DIRS})
+    target_link_directories(plutosdr_source PRIVATE ${LIBIIO_LIBRARY_DIRS})
+    target_link_libraries(plutosdr_source PRIVATE ${LIBIIO_LIBRARIES})

-        target_include_directories(plutosdr_source PRIVATE ${LIBIIO_INCLUDE_DIRS})
-        target_link_directories(plutosdr_source PRIVATE ${LIBIIO_LIBRARY_DIRS})
-        target_link_libraries(plutosdr_source PRIVATE ${LIBIIO_LIBRARIES})
-
-        target_include_directories(plutosdr_source PRIVATE ${LIBAD9361_INCLUDE_DIRS})
-        target_link_directories(plutosdr_source PRIVATE ${LIBAD9361_LIBRARY_DIRS})
-        target_link_libraries(plutosdr_source PRIVATE ${LIBAD9361_LIBRARIES})
-    endif()
+    target_include_directories(plutosdr_source PRIVATE ${LIBAD9361_INCLUDE_DIRS})
+    target_link_directories(plutosdr_source PRIVATE ${LIBAD9361_LIBRARY_DIRS})
+    target_link_libraries(plutosdr_source PRIVATE ${LIBAD9361_LIBRARIES})

     target_include_directories(plutosdr_source PRIVATE ${LIBAD9361_INCLUDE_DIRS})
-endif ()
\ No newline at end of file
+endif ()
