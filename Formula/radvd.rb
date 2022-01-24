class Radvd < Formula
  desc "IPv6 Router Advertisement Daemon"
  homepage "https://radvd.litech.org/"
  url "https://github.com/radvd-project/radvd/releases/download/v2.19/radvd-2.19.tar.xz"
  sha256 "564e04597f71a9057d02290da0dd21b592d277ceb0e7277550991d788213e240"
  license "NOASSERTION"

  livecheck do
    url :stable
    strategy :github_latest
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  head do
    url "https://github.com/radvd-project/radvd.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  uses_from_macos "bison" => :build

  def install
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system "false"
  end
end
