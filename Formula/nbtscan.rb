class Nbtscan < Formula
  desc "Scan networks searching for NetBIOS information"
  homepage "https://github.com/resurrecting-open-source-projects/nbtscan"
  url "https://github.com/resurrecting-open-source-projects/nbtscan/archive/refs/tags/1.7.2.tar.gz"
  sha256 "00e61be7c05cd3a34d5fefedffff86dc6add02d4c728b22e13fb9fbeabba1984"
  license "GPL-2.0-or-later"
  head "https://github.com/resurrecting-open-source-projects/nbtscan.git", branch: "master"

  livecheck do
    url :homepage
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    system "./autogen.sh"
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system bin/"nbtscan", "127.0.0.1"
  end
end
