class RockyouList < Formula
  desc "Kali Linux word list rockyou.txt"
  homepage "https://gitlab.com/kalilinux/packages/wordlists"
  url "https://gitlab.com/kalilinux/packages/wordlists/-/raw/debian/0.3-1kali3/rockyou.txt.gz"
  sha256 "ded2d962815e1256df8f3a0d25173c4b21b6eee636117c36999246725a6d8f9f"
  license "Free"

  def install
    mkdir "#{share}/wordlists"
    cp "rockyou.txt", "#{share}/wordlists"
  end

  test do
    system "false"
  end
end
