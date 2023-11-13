cask "obs-rtspserver" do
  version "3.0.0"
  sha256 "b467d04f1af7763d942a13815dd0ae50ad7e6f62be4630048326565c70fcfd17"

  url "https://github.com/iamscottxu/obs-rtspserver/releases/download/v#{version}/obs-rtspserver-v#{version}-macos-universal.pkg"
  name "obs-rtspserver"
  desc "RTSP server plugin for obs-studio"
  homepage "https://github.com/iamscottxu/obs-rtspserver"

  pkg "obs-rtspserver-v#{version}-macos-universal.pkg"

  uninstall pkgutil: "com.scottxu.obs-rtspserver"
end
