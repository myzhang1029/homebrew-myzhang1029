cask "amazon-corretto-8" do
  version "8.422.05.1"
  sha256 "45fe10295e65f70d6ec46e3441509737d17e45d198c1f6b00b365367a3983909"

  url "https://corretto.aws/downloads/resources/#{version}/amazon-corretto-#{version}-macosx-aarch64.pkg"
  name "amazon-corretto-8"
  desc "OpenJDK distribution from Amazon, version 8"
  homepage "https://corretto.aws/"

  livecheck do
    url "https://github.com/corretto/corretto-8"
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest do |json, regex|
      match = json["tag_name"]&.match(regex)
      next if match.blank?

      match[1]
    end
  end

  pkg "amazon-corretto-#{version}-macosx-aarch64.pkg"

  uninstall pkgutil: "com.amazon.corretto.#{version.major}"
end
