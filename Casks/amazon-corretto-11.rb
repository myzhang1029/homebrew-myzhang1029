cask "amazon-corretto-11" do
  version "11.0.24.8.1"
  sha256 "ef98479f69dc2d7d65280ba300541d7e24832d7b4837014885550b9442c23854"

  url "https://corretto.aws/downloads/resources/#{version}/amazon-corretto-#{version}-macosx-aarch64.pkg"
  name "amazon-corretto-11"
  desc "OpenJDK distribution from Amazon, version 11"
  homepage "https://corretto.aws/"

  livecheck do
    url "https://github.com/corretto/corretto-11"
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
