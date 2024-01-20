cask "amazon-corretto-8" do
  version "8.402.08.1"
  sha256 "8fa923be1c52a9bec98ece6c5a3c9cb8b2c2cab618cff852edc27939c0efafc1"

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
