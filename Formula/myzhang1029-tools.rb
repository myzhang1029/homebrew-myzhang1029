class Myzhang1029Tools < Formula
  desc "My collection of tools"
  homepage "https://github.com/myzhang1029"
  url "https://example.com/index.html"
  version "1.0"
  license "CC0-1.0"

  depends_on "aria2"
  depends_on "arping"
  depends_on "aspell"
  depends_on "autoconf"
  depends_on "autoconf-archive"
  depends_on "automake"
  depends_on "clang-format"
  depends_on "cmake"
  depends_on "coreutils"
  depends_on "exiftool"
  depends_on "fdupes"
  depends_on "ffmpeg"
  depends_on "geckodriver"
  depends_on "gh"
  depends_on "ghostscript"
  depends_on "git-lfs"
  depends_on "gnupg"
  depends_on "gnuplot"
  depends_on "hashcat"
  depends_on "hashcat-utils"
  depends_on "htop"
  depends_on "imagemagick"
  depends_on "iperf3"
  depends_on "jq"
  depends_on "lame"
  depends_on "libarchive"
  depends_on "libtool"
  depends_on "lsusb"
  depends_on "lzip"
  depends_on "md5deep"
  depends_on "mitmproxy"
  depends_on "mosh"
  depends_on "nbtscan"
  depends_on "ndisc6"
  depends_on "neovim"
  depends_on "ninja"
  depends_on "nmap"
  depends_on "opencc"
  depends_on "pdf2svg"
  depends_on "plzip"
  depends_on "proxychains-ng"
  depends_on "pv"
  depends_on "radvd"
  depends_on "shellcheck"
  depends_on "smartmontools"
  depends_on "sox"
  depends_on "tarlz"
  depends_on "telnet"
  depends_on "tmux"
  depends_on "tor"
  depends_on "trash"
  depends_on "you-get"
  depends_on "yt-dlp"
  depends_on "zmap"
  depends_on "zstd"

  def install
    system "sh", "-c", "echo installed > #{prefix}/myzhang1029-tools"
  end

  test do
    system "ls", "#{prefix}/myzhang1029-tools"
  end
end
