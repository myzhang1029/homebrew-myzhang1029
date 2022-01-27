# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Nbtscan < Formula
  desc "Scan networks searching for NetBIOS information"
  homepage "https://github.com/resurrecting-open-source-projects/nbtscan"
  url "https://github.com/resurrecting-open-source-projects/nbtscan/archive/refs/tags/1.7.2.tar.gz"
  sha256 "00e61be7c05cd3a34d5fefedffff86dc6add02d4c728b22e13fb9fbeabba1984"
  license "GPL-2.0"
  head "https://github.com/resurrecting-open-source-projects/nbtscan.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/?(\d+(?:\.\d+)+)["' >]}i)
  end

  depends_on "automake" => :build
  depends_on "autoconf" => :build

  def install
    system "./autogen.sh"
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system bin/"nbtscan", "127.0.0.1"
  end
end
