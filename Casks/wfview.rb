cask "wfview" do
  version "2.03"
  sha256 "d7b749632d4db87e43f56111818c446b0a1532f3bf4a61c0a4fe20b3fa5d7cf6"

  version_for_url = version.tr(".", "-")
  url "https://wfview.org/download/macos-universal-v#{version_for_url}/?wpdmdl=1417&refresh=679bbd286f5321738259752"
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
