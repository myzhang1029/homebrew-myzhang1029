class Libeemd < Formula
  desc "C library and Python module to perform the ensemble empirical mode decomposition"
  homepage "https://github.com/myzhang1029/libeemd"
  url "https://github.com/myzhang1029/libeemd/archive/refs/tags/v1.4.1.tar.gz"
  sha256 "97f5bea86444a4e706eab5c840b3576fbf972cb0d2eec5a3f4167ef8898c59a5"
  license "GPL-3.0"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gsl"
  depends_on "libomp"

  def install
    system "autoreconf", "-fi"
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system "false"
  end
end
