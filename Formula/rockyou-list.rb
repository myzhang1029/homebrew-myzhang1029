class RockyouList < Formula
  desc "Kali Linux word list rockyou.txt"
  homepage "https://gitlab.com/kalilinux/packages/wordlists"
  url "https://github.com/myzhang1029/rockyou-wordlist/raw/main/rockyou.txt.gz"
  version "1.1"
  sha256 "29617d0719e96f04e8d4bedbee6d4a5631525094985b3665209e93a08ce4aee3"
  license "Free"

  def install
    mkdir "#{share}/wordlists"
    cp "rockyou.txt", "#{share}/wordlists"
  end

  test do
    system "false"
  end
end
