cask "amazon-corretto-8" do
  version "8.452.09.1"
  sha256 "2e1fd55e3545e62b2257e55e68d07ad9c76e053a1b1553653fec0cfef0bbadc8"

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
