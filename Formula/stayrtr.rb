class Stayrtr < Formula
  desc "RPKI-To-Router server implementation in Go"
  homepage "https://github.com/bgp/stayrtr"
  url "https://github.com/bgp/stayrtr/archive/refs/tags/v0.6.2.tar.gz"
  sha256 "061a2cab6e3827c72f36fbcbfbf1379b4c5b29bdea4d6c902e067c000c5b8c9d"
  license "BSD-3-Clause"

  depends_on "go" => :build

  def install
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    os = OS.linux? ? "linux" : "darwin"
    ENV["GOARCH"] = arch
    ENV["GOOS"] = os
    system "make", "build-all"
    mkdir bin
    cp "dist/stayrtr--#{os}-#{arch}", "#{bin}/stayrtr"
    cp "dist/rtrdump--#{os}-#{arch}", "#{bin}/rtrdump"
    cp "dist/rtrmon--#{os}-#{arch}", "#{bin}/rtrmon"
  end

  test do
    system "stayrtr", "-version"
    system "rtrdump", "-version"
    system "rtrmon", "-version"
  end
end
