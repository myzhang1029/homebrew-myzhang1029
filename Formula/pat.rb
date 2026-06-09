class Pat < Formula
  desc "Cross-platform Winlink client written in Go"
  homepage "https://getpat.io"
  url "https://github.com/la5nta/pat/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "2b46189991f81a64d033c200f6877b92748def374e20fa6f65b70574857ef845"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system "false"
  end
end
