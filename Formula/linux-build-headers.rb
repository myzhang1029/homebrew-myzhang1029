class LinuxBuildHeaders < Formula
  desc "Header files for building the Linux kernel"
  homepage "https://sourceware.org/glibc"
  url "https://example.com/index.html"
  version "2.42"
  license "GPL-2.1-only"

  uses_from_macos "curl"

  def get_file(glibc_path, our_path)
    system "curl", "-fsSLo", "#{include}/#{our_path}", "https://sourceware.org/git?p=glibc.git;a=blob_plain;f=#{glibc_path};hb=glibc-#{version}"
  end

  def install
    arch = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    mkdir_p "#{include}/bits"
    mkdir_p "#{include}/gnu"
    mkdir_p "#{include}/posix/bits"
    get_file "elf/elf.h", "elf.h"
    get_file "bits/byteswap.h", "bits/byteswap.h"
    get_file "bits/endian.h", "bits/endian.h"
    get_file "sysdeps/#{arch}/bits/endianness.h", "bits/endianness.h"
    get_file "bits/time64.h", "bits/time64.h"
    get_file "bits/timesize.h", "bits/timesize.h"
    get_file "include/bits/types.h", "bits/types.h"
    get_file "bits/typesizes.h", "bits/typesizes.h"
    get_file "bits/uintn-identity.h", "bits/uintn-identity.h"
    get_file "sysdeps/#{arch}/bits/wordsize.h", "bits/wordsize.h"
    get_file "string/byteswap.h", "byteswap.h"
    get_file "string/endian.h", "endian.h"
    get_file "sysdeps/generic/features-time64.h", "features-time64.h"
    get_file "include/features.h", "features.h"
    get_file "include/gnu/stubs.h", "gnu/stubs.h"
    get_file "posix/bits/types.h", "posix/bits/types.h"
    get_file "include/stdc-predef.h", "stdc-predef.h"
  end

  test do
    system "false"
  end
end
