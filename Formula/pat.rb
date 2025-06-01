class Pat < Formula
  desc "Cross-platform Winlink client written in Go"
  homepage "https://getpat.io"
  url "https://github.com/la5nta/pat/archive/refs/tags/v0.17.0.tar.gz"
  sha256 "a8daf4d693cef17f906dcd192e5531830e35a980ac90f98a2a7ddac1602811b0"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system "false"
  end
end
