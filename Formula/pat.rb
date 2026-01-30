class Pat < Formula
  desc "Cross-platform Winlink client written in Go"
  homepage "https://getpat.io"
  url "https://github.com/la5nta/pat/archive/refs/tags/v0.19.2.tar.gz"
  sha256 "d630001c81a4f0cb461735b1f0d17af19f23de2e10812b28f5d2d96e654ad800"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system "false"
  end
end
