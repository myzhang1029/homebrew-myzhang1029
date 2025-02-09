cask "amazon-corretto-11" do
  version "11.0.26.4.1"
  sha256 "cede642e444e10c50b0834b1dc2388c14e17198caf2a6ee204ee6316d8c506a6"

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
