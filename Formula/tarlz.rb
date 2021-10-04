class Tarlz < Formula
  desc "Parallel combined implementation of the tar archiver and the lzip compressor"
  homepage "https://lzip.nongnu.org/tarlz.html"
  url "https://download.savannah.gnu.org/releases/lzip/tarlz/tarlz-0.21.tar.lz"
  sha256 "0f972112dd3f126a394d5a04107695ccbbb9e603e7b193367bd1714607e0adf4"
  license "GPL-2.0-or-later"

  def install
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system "make", "check"
  end
end
