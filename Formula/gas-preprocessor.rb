class GasPreprocessor < Formula
  desc "Perl script that implements a subset of the GNU as preprocessor"
  homepage "https://github.com/myzhang1029/gas-preprocessor"
  url "https://github.com/myzhang1029/gas-preprocessor/raw/master/gas-preprocessor.pl"
  version "latest"
  sha256 "beebd47ee4ef49a3d69183b1b3142e2b8c28fe68d6bc37bf8ff8a6f3cde56584"
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
