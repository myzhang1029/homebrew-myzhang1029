class HashcatUtils < Formula
  desc "Small utilities that are useful in advanced password cracking"
  homepage "https://hashcat.net/wiki/doku.php?id=hashcat_utils"
  url "https://github.com/hashcat/hashcat-utils/archive/refs/tags/v1.10.tar.gz"
  sha256 "0f2ea19ee0ed12593e991aa73d6ffdf2c38b54e11dca43fa25f14d46945d2642"
  license "MIT"

  livecheck do
    url "https://github.com/hashcat/hashcat-utils.git"
  end

  def install
    system "make", "-C", "src", "native"
    mkdir bin
    system "sh", "-c", <<~HEREDOC
      for bin in src/*.bin
      do
        install -c -s -m 755 "$bin" "#{bin}/$(basename "$bin" | cut -f1 -d.)"
      done
    HEREDOC
  end

  test do
    system "false"
  end
end
