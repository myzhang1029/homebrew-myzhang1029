class Pat < Formula
  desc "Cross-platform Winlink client written in Go"
  homepage "https://getpat.io"
  url "https://github.com/la5nta/pat/archive/refs/tags/v0.16.0.tar.gz"
  sha256 "e2ac18531bbe2d3e8ac9939490ef2fb7f4d1c9efd236166a68e2cd28a5a650fa"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    system "false"
  end
end
