cask "amazon-corretto-8" do
  version "8.442.06.1"
  sha256 "119d5b91de9cfb959a4a872914a274e43db321fc4df75f0a0f9f6fed516c5143"

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
