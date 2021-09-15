cask "jamwifi" do
  version "1.3.2"
  sha256 "8f11ef09a09eda1990795c22ac1eb3272a88c7ffb4558ab2c0a5a637e7d251bc"

  url "https://github.com/0x0XDev/JamWiFi/releases/download/v#{version}/JamWiFi.zip"
  name "JamWiFi"
  desc "GUI WiFi network jammer"
  homepage "https://github.com/0x0XDev/JamWiFi"

  livecheck do
    url "https://github.com/0x0XDev/JamWiFi.git"
  end

  app "JamWiFi.app"
end
