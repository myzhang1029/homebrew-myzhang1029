class RockyouList < Formula
  desc "Kali Linux word list rockyou.txt"
  homepage "https://gitlab.com/kalilinux/packages/wordlists"
  url "https://github.com/myzhang1029/rockyou-wordlist/raw/main/rockyou.txt.gz"
  version "1.1"
  sha256 "5324796f5cf98e3daa168c90662a003a84183f4c8c26c07a629b641d426c2be7"
  license "Free"

  def install
    mkdir "#{share}/wordlists"
    cp "rockyou.txt", "#{share}/wordlists"
  end

  test do
    system "false"
  end
end
