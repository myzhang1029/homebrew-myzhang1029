class Klayout < Formula
  desc "Your mask layout friend"
  homepage "http://www.klayout.org"
  license "GPL-3.0"
  head "https://github.com/KLayout/klayout.git"

  depends_on "libgit2"
  depends_on "python"
  depends_on "qt"
  depends_on "ruby@3.4"

  def install
    # ENV["AR"] = "ar"
    # ENV["OBJCOPY"] = "objcopy"
    # system "./build.sh", "-libcurl", "-libexpat", "-expert", "-pylib",
    # "#{HOMEBREW_PREFIX}/opt/python/Frameworks/Python.framework/Python"
    system "./build4mac.py", "-q", "qt6brew", "-r", "hb34", "-p", "sys"
    system "./build4mac.py", "-q", "qt6brew", "-r", "hb34", "-p", "sys", "-Y"
    prefix.install Dir["LW*.macos-*-release-*/klayout.app"]
  end

  def caveats
    <<~EOS
      This installation script does not link the app to /Applications.

      To find klayout in Launchpad, run
      ```
      ln -s #{opt_prefix}/klayout.app /Application
      ```
    EOS
  end

  test do
    system "false"
  end
end
