class Sibsecsh < Formula
  desc "Secure 2FA shell in Rust"
  homepage "https://github.com/myzhang1029/sibsecsh"
  url "https://github.com/myzhang1029/sibsecsh/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "2260018751f78ade862b79b605b723abe2d6ece246b2f7dbb43e79b2491a8608"
  license "AGPL-3.0-or-later"

  livecheck do
    url :homepage
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    system "false"
  end
end
