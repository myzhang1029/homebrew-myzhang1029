class FfmpegAudacity < Formula
  desc "Play, record, convert, and stream audio and video"
  homepage "https://ffmpeg.org/"
  url "https://ffmpeg.org/releases/ffmpeg-2.3.6.tar.bz2"
  sha256 "cf1be1c5c3973b8db16b6b6e8e63a042d414fb5d47d3801a196cbba21a0a624a"
  # None of these parts are used by default, you have to explicitly pass `--enable-gpl`
  # to configure to activate them. In this case, FFmpeg's license changes to GPL v2+.
  license "GPL-2.0-or-later"
  revision 2

  keg_only :versioned_formulae, "this old version is for Audacity and may clash with latest ffmpeg"

  depends_on "gas-preprocessor" => :build
  depends_on "pkg-config" => :build
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "frei0r"
  depends_on "gnutls"
  depends_on "lame"
  depends_on "libass"
  depends_on "libbluray"
  depends_on "libgsm"
  depends_on "libsoxr"
  depends_on "libvidstab"
  depends_on "libvorbis"
  depends_on "opencore-amr"
  depends_on "opus"
  depends_on "speex"
  depends_on "theora"
  depends_on "webp"
  depends_on "x265"
  depends_on "xvid"
  depends_on "zeromq"
  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  # libx264 and libvpx breaks the build because of incompatiable versions
  def install
    args = %W[
      --enable-frei0r
      --enable-gpl
      --enable-nonfree
      --enable-gnutls
      --enable-libass
      --enable-libbluray
      --enable-libfontconfig
      --enable-libfreetype
      --enable-libfribidi
      --enable-libgsm
      --enable-libmp3lame
      --enable-libopencore-amrnb
      --enable-libopencore-amrwb
      --enable-libopus
      --enable-libsoxr
      --enable-libspeex
      --enable-libtheora
      --enable-libvidstab
      --enable-libvorbis
      --enable-libwebp
      --enable-libx265
      --enable-libxvid
      --enable-libzmq
      --enable-opencl
      --enable-opengl
      --enable-lto
      --enable-version3
      --cc=#{ENV.cc}
      --host-cflags=#{ENV.cflags}
      --host-ldflags=#{ENV.ldflags}
      --disable-programs
      --disable-avdevice
      --disable-debug
      --enable-shared
      --enable-pthreads
      --prefix=#{prefix}
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    # Create an example mp4 file
    mp4out = testpath/"video.mp4"
    system bin/"ffmpeg", "-filter_complex", "testsrc=rate=1:duration=1", mp4out
    assert_predicate mp4out, :exist?
  end
end
