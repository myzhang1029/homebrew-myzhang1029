class Slib < Formula
  desc "Portable programming interface library written in C for any usage"
  homepage "https://github.com/myzhang1029/slib"
  url "https://github.com/myzhang1029/slib/archive/refs/tags/v4.5.1.tar.gz"
  sha256 "a6502560fc40efa283aa4f9635e069e8a5af9ef4f1721df28c13dac2a86bd354"
  license "LGPL-3.0-or-later"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "cmake", "test"
  end
end
