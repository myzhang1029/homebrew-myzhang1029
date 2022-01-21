class GasPreprocessor < Formula
  desc "Perl script that implements a subset of the GNU as preprocessor"
  homepage "https://github.com/myzhang1029/gas-preprocessor"
  url "https://github.com/myzhang1029/gas-preprocessor/raw/master/gas-preprocessor.pl"
  version "latest"
  sha256 "92bcf5b68bb67fdc102373b96fd8177cb49320b0b290d89714aa71b5486f3fed"
  license "GPL-2.0-or-later"

  def install
    mkdir bin
    cp "gas-preprocessor.pl", bin
    chmod 0755, "#{bin}/gas-preprocessor.pl"
  end

  test do
    system "false"
  end
end
