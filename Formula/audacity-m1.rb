class AudacityM1 < Formula
  desc "Multi-track audio editor and recorder"
  homepage "https://www.audacityteam.org/"
  url "https://github.com/myzhang1029/audacity-applesilicon/archive/refs/heads/arm64-macos.tar.gz"
  version "3.1.3-alpha"
  license "GPL-2.0-only"
  head "https://github.com/myzhang1029/audacity-applesilicon.git", branch: "arm64-macos"

  deprecate! date:    "2022-01-25",
             because: "is done in audacity/audacity #2416. Please download official arm64 releases"

  depends_on "cmake" => :build
  depends_on "conan" => :build
  depends_on arch: :arm64
  # Optional FFmpeg support, also for M1
  depends_on "myzhang1029/myzhang1029/ffmpeg-audacity" => :recommended

  def install
    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_OSX_ARCHITECTURES=arm64", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      This installation script does not link the app to /Applications.

      To find audacity-m1 in Launchpad, run
      ```
      ln -s #{opt_prefix}/Audacity.app ~/Applications/AudacityM1.app
      ```
    EOS
  end

  test do
    system "false"
  end
end
