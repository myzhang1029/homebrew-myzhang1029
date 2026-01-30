class LinuxBuildHeaders < Formula
  # To be used with HOST_EXTRACFLAGS=-I/opt/homebrew/opt/linux-build-headers/include make LLVM=1
  desc "Header files for building the Linux kernel"
  homepage "https://sourceware.org/glibc"
  url "https://ftp.gnu.org/gnu/glibc/glibc-2.43.tar.xz"
  sha256 "d9c86c6b5dbddb43a3e08270c5844fc5177d19442cf5b8df4be7c07cd5fa3831"
  license "GPL-2.1-only"
  head "https://sourceware.org/git/glibc.git"

  keg_only "it will conflict with macOS headers"

  def install
    arch = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    mkdir_p include/"bits"
    mkdir_p include/"gnu"
    mkdir_p include/"posix/bits"
    cp "elf/elf.h", include/"elf.h"
    cp "bits/byteswap.h", include/"bits/byteswap.h"
    cp "string/bits/endian.h", include/"bits/endian.h"
    cp "sysdeps/#{arch}/bits/endianness.h", include/"bits/endianness.h"
    cp "bits/time64.h", include/"bits/time64.h"
    cp "bits/timesize.h", include/"bits/timesize.h"
    cp "include/bits/types.h", include/"bits/types.h"
    cp "bits/typesizes.h", include/"bits/typesizes.h"
    cp "bits/uintn-identity.h", include/"bits/uintn-identity.h"
    cp "sysdeps/#{arch}/bits/wordsize.h", include/"bits/wordsize.h"
    cp "string/byteswap.h", include/"byteswap.h"
    cp "string/endian.h", include/"endian.h"
    cp "sysdeps/generic/features-time64.h", include/"features-time64.h"
    cp "include/features.h", include/"features.h"
    cp "include/gnu/stubs.h", include/"gnu/stubs.h"
    cp "posix/bits/types.h", include/"posix/bits/types.h"
    cp "include/stdc-predef.h", include/"stdc-predef.h"
    # Resolve duplicate __int64_t definitions
    system "sed", "-i.bak", "s/typedef signed long int __int64_t//;s/typedef unsigned long int __uint64_t//",
"#{include}/posix/bits/types.h"
  end

  test do
    system "false"
  end
end
