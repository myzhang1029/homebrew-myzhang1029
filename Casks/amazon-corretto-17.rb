cask "amazon-corretto-17" do
  version "17.0.15.6.1"
  sha256 "221aeb8b1952c6839558c634389cab2d4bbcab9f1d1f7034845fd5847466e589"

  url "https://corretto.aws/downloads/resources/#{version}/amazon-corretto-#{version}-macosx-aarch64.pkg"
  name "amazon-corretto-11"
  desc "OpenJDK distribution from Amazon, version 17"
  homepage "https://corretto.aws/"

  deprecate! date:    "2025-09-22",
             because: "is replaced by homebrew/cask/corretto@17"

  pkg "amazon-corretto-#{version}-macosx-aarch64.pkg"

  uninstall pkgutil: "com.amazon.corretto.#{version.major}"
end
