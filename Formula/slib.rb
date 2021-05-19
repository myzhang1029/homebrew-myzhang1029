class Slib < Formula
  desc "Portable programming interface library written in C for any usage"
  homepage "https://github.com/myzhang1029/slib"
  url "https://github.com/myzhang1029/slib/archive/refs/tags/v4.5.2.tar.gz"
  sha256 "8fd681cde527805607b7348cce153413f25b920a953601af506e7c2dfe1b7f33"
  license "LGPL-3.0-or-later"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", "-DCMAKE_MACOSX_RPATH=OFF", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "cmake", "test"
  end
end
