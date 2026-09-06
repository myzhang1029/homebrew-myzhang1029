class Libvidcap < Formula
  desc "a cross-platform library for capturing video from webcams and other video capture devices"
  homepage "https://sourceforge.net/projects/libvidcap/"
  url "https://sourceforge.net/projects/libvidcap/files/libvidcap/0.2.1/libvidcap-0.2.1.tar.gz/download"
  sha256 "50bdabe1bb809e52677c3d5a02e118ce4a6d22828e42aebc8741e5b9a042741a"
  license ""

  def install
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
