class Librepcb < Formula
  desc "Powerful, innovative and intuitive EDA tool for everyone!"
  homepage "https://librepcb.org"
  url "https://download.librepcb.org/releases/0.1.6/librepcb-0.1.6-source.zip"
  sha256 "8c7bf475ed59eb5b5e4b13073b96b9468ee01fb6980ef2b3471b1fbb39c46721"
  license "GPL-3.0-or-later"

  head "https://github.com/LibrePCB/LibrePCB.git", branch: "master"

  livecheck do
    url "https://download.librepcb.org/releases"
    regex(%r{href=.*?v?(\d+(?:\.\d+)+)/}i)
  end

  depends_on "cmake" => :build
  depends_on "openssl"
  depends_on "qt@5"
  depends_on "zlib"

  def install
    system "cmake", "-S", ".", "-B", "build", "-DLIBREPCB_SHARE=#{share}/librepcb", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "false"
  end
end
