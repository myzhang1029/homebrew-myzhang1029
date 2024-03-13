class Libbgp < Formula
  desc "C++ BGP library"
  homepage "https://lab.nat.moe/libbgp-doc"
  url "https://github.com/Nat-Lab/libbgp/archive/refs/tags/0.6.3.tar.gz"
  sha256 "403c1790f9a7f696fbafb133368361f07ae73ebe81d4848921c2db644d4bb851"
  license "MIT"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system ENV.cxx, "examples/deserialize-and-serialize.cc", "-lbgp", "-o", "deserialize-and-serialize"
  end
end
