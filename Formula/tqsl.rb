class Tqsl < Formula
  desc "Tools for digitally signing Amateur Radio QSO records"
  homepage "https://www.arrl.org/tqsl-download"
  url "https://www.arrl.org/tqsl/tqsl-2.7.3.tar.gz"
  sha256 "09af4fb32b633efad4e2ef9bff1ea921b41cf020cd588ea134cea317ad0176cf"

  livecheck do
    url :homepage
    regex(/href=.*?tqsl[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "cmake" => :build
  depends_on "berkeley-db"
  depends_on "curl"
  depends_on "expat"
  depends_on "wxwidgets"
  depends_on "zlib"

  def install
    arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
    system "cmake",
      "-S", ".", "-B", "build",
      # Override the default `i386` architecture
      "-UOSX_ARCH", "-DOSX_ARCH=#{arch}",
      # TQSL does not want to use @rpath, so we make things static
      "-DTQSLLIB_STATIC=ON",
      # CMake does not know how to find berkeley-db
      "-DBDB_INCLUDE_DIR=#{Formula["berkeley-db"].opt_include}",
      "-DBDB_LIBRARY=#{Formula["berkeley-db"].opt_lib}/libdb.dylib",
      *std_cmake_args
    system "cmake", "--build", "build"
    cp_r "build/apps/tqsl.app", prefix
    # Copy config.xml or TQSL will not start
    cp "src/config.xml", "#{prefix}/tqsl.app/Contents/Resources"
  end

  def caveats
    <<~EOS
      This installation script does not link the app to /Applications.

      To find TQSL in Launchpad, run
      ```
      ln -s #{opt_prefix}/tqsl.app ~/Applications/tqsl.app
      ```
    EOS
  end

  test do
    system "ls", "build/apps/tqsl.app/Contents/MacOS/tqsl"
  end
end
