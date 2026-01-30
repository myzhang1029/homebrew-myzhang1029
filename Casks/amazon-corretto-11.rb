cask "amazon-corretto-11" do
  version "11.0.27.6.1"
  sha256 "fcf184611f98e303c53e4c942b8742d5cff01e6cb9c7876011e6b12651a0062a"

  url "https://corretto.aws/downloads/resources/#{version}/amazon-corretto-#{version}-macosx-aarch64.pkg"
  name "amazon-corretto-11"
  desc "OpenJDK distribution from Amazon, version 11"
  homepage "https://corretto.aws/"

  deprecate! date:    "2025-09-22",
             because: "is replaced by homebrew/cask/corretto@11"

  pkg "amazon-corretto-#{version}-macosx-aarch64.pkg"

  uninstall pkgutil: "com.amazon.corretto.#{version.major}"
end
