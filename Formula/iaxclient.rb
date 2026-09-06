class Iaxclient < Formula
  desc ""
  homepage ""
  url "https://sourceforge.net/projects/iaxclient/files/iaxclient/2.1beta3/iaxclient-2.1beta3.tar.gz/download"
  sha256 "6ca6ce8103837ed6fa2fd2e88c1c0d3a3d93d7b4bd084878351527ebfb205149"
  license ""

  depends_on "portaudio"
  depends_on "speex"
  depends_on "speexdsp"
  depends_on "ogg"
  depends_on "oggz"
  depends_on "theora"
  depends_on "ffmpeg"
  depends_on "libvidcap"

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
