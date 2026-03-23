class Stayrtr < Formula
  desc "RPKI-To-Router server implementation in Go"
  homepage "https://github.com/bgp/stayrtr"
  url "https://github.com/bgp/stayrtr/archive/refs/tags/v0.6.4.tar.gz"
  sha256 "f514fb336fab43d080b9a29f1e8336e330515db6b19e8d26ba5b1f266d31ed73"
  license "BSD-3-Clause"

  depends_on "go" => :build

  def install
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    os = OS.linux? ? "linux" : "darwin"
    ENV["GOARCH"] = arch
    ENV["GOOS"] = os
    system "make", "build-all"
    mkdir bin
    cp "dist/stayrtr--#{os}-#{arch}", bin/"stayrtr"
    cp "dist/rtrdump--#{os}-#{arch}", bin/"rtrdump"
    cp "dist/rtrmon--#{os}-#{arch}", bin/"rtrmon"
  end

  test do
    system bin/"stayrtr", "-version"
    system bin/"rtrdump", "-version"
    system bin/"rtrmon", "-version"
  end
end
