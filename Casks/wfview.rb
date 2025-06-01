cask "wfview" do
  version "2.11"
  sha256 "fd5b89d9eea1a70c80691894284df5ee4f2a85da5bbc7f46e5cf5bb83832cc6d"

  version_for_url = version.tr(".", "-")
  url "https://wfview.org/download/macos-universal-v#{version_for_url}/?wpdmdl=1594&refresh=683a1570d13ea1748637040"
  name "wfview"
  desc "Open Source interface for Icom and Kenwood transceivers"
  homepage "https://wfview.org/"

  livecheck do
    url "https://gitlab.com/eliggett/wfview.git"
  end

  depends_on macos: ">= :monterey"

  app "wfview.app"

  zap trash: [
    "~/Library/Application Scripts/org.wfview.wfview",
    "~/Library/Containers/org.wfview.wfview",
  ]
end
