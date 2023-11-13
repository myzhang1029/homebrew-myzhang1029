cask "obs-rtspserver" do
  version "2.3.0"
  sha256 "df2154b488b7c9f32abe61c88715c3c34ef7255b73a51849af1ace3fc1df5b38"

  url "https://github.com/iamscottxu/obs-rtspserver/releases/download/v#{version}/obs-rtspserver-v#{version}-macos-universal.pkg"
  name "obs-rtspserver"
  desc "RTSP server plugin for obs-studio"
  homepage "https://github.com/iamscottxu/obs-rtspserver"

  pkg "obs-rtspserver-v#{version}-macos-universal.pkg"

  uninstall pkgutil: "com.scottxu.obs-rtspserver"
end
