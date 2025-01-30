cask "amazon-corretto-17" do
  version "17.0.14.7.1"
  sha256 "e168900460d2bb6c887d3a9e90918f2d2568d58e4da17cb208318176c804cc1f"

  url "https://corretto.aws/downloads/resources/#{version}/amazon-corretto-#{version}-macosx-aarch64.pkg"
  name "amazon-corretto-11"
  desc "OpenJDK distribution from Amazon, version 17"
  homepage "https://corretto.aws/"

  livecheck do
    url "https://github.com/corretto/corretto-17"
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
