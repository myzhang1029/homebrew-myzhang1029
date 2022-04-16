cask "macos-monitor-previewer" do
  version "1.1"
  sha256 "2c309cf3255fc0312a5a4db076e461500aa947c94ec666dfd6dfbe47efb9e784"

  url "https://github.com/myzhang1029/macOS-Monitor-Previewer/releases/download/v#{version}/Monitor.Preview.app.zip"
  name "macOS-Monitor-Previewer"
  desc "Preview another monitor on the main display"
  homepage "https://github.com/myzhang1029/macOS-Monitor-Previewer"

  app "Monitor Preview.app"

  zap trash: [
    "~/Library/Application Scripts/xyz.myzhangll.Monitor-Preview",
    "~/Library/Containers/xyz.myzhangll.Monitor-Preview",
  ]
end
