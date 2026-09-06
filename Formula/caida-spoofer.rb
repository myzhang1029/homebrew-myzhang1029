class CaidaSpoofer < Formula
  desc "CAIDA's Source Address Validation Measurement Project"
  homepage "https://www.caida.org/projects/spoofer/"
  url "https://www.caida.org/projects/spoofer/downloads/spoofer-1.5.0.tar.gz"
  sha256 "b9641c7ca02cf07a3c661fbaedec515493b233d8beb20bbfeedf2fb95586c885"
  license ""

  depends_on "pkgconf" => :build
  depends_on "openssl"
  depends_on "protobuf@21"
  depends_on "scamper"
  uses_from_macos "libpcap"

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
