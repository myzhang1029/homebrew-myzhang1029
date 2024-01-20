cask "obs-rtspserver" do
  version "3.1.0"
  sha256 "c121195940cd8c43e2cdc73f730bc1655fbd1582fdc654e0170cb0f98687ab1e"

  url "https://github.com/iamscottxu/obs-rtspserver/releases/download/v#{version}/obs-rtspserver-v#{version}-macos-universal.pkg"
  name "obs-rtspserver"
  desc "RTSP server plugin for obs-studio"
  homepage "https://github.com/iamscottxu/obs-rtspserver"

  pkg "obs-rtspserver-v#{version}-macos-universal.pkg"

  uninstall pkgutil: "com.scottxu.obs-rtspserver"
end
