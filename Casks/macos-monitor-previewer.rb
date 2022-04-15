cask "macos-monitor-previewer" do
  version "1.0"
  sha256 "2ec84af1238afbfe10c8b41bca092760350fa5aef21439ced45b80f035d77129"

  url "https://github.com/myzhang1029/macOS-Monitor-Previewer/releases/download/v#{version}/Monitor.Preview.app.zip"
  name "macOS-Monitor-Previewer"
  desc "Preview another monitor on the main display"
  homepage "https://github.com/myzhang1029/macOS-Monitor-Previewer"

  app "Monitor Preview.app"
end
