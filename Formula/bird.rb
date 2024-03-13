class Bird < Formula
  desc "Internet Routing Daemon"
  homepage "https://bird.network.cz/"
  license "GPL-2.0-or-later"
  head "https://gitlab.nic.cz/labs/bird.git"

  depends_on "autoconf" => :build
  depends_on "bison" => :build
  depends_on "libssh"
  depends_on "readline"

  patch :DATA

  def install
    system "autoreconf", "-fi"
    system "./configure", "--sysconfdir=#{etc}", "--runstatedir=#{var}/run", "--with-sysconfig=bsd",
"--enable-libssh", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    system sbin/"bird", "--version"
  end
end

__END__
diff --git a/sysdep/bsd/krt-sock.c b/sysdep/bsd/krt-sock.c
index d13e20a3..afb66cb3 100644
--- a/sysdep/bsd/krt-sock.c
+++ b/sysdep/bsd/krt-sock.c
@@ -635,6 +635,7 @@ krt_read_route(struct ks_msg *msg, struct krt_proto *p, int scan)
     krt_got_route_async(p, e, new, src);
 }
 
+#ifndef __APPLE__
 static void
 krt_read_ifannounce(struct ks_msg *msg)
 {
@@ -661,6 +662,7 @@ krt_read_ifannounce(struct ks_msg *msg)
 
   DBG("KRT: IFANNOUNCE what: %d index %d name %s\n", ifam->ifan_what, ifam->ifan_index, ifam->ifan_name);
 }
+#endif
 
 static void
 krt_read_ifinfo(struct ks_msg *msg, int scan)
@@ -725,7 +727,9 @@ krt_read_ifinfo(struct ks_msg *msg, int scan)
 
   if (fl & IFF_UP)
     f.flags |= IF_ADMIN_UP;
+#ifndef __APPLE__
   if (ifm->ifm_data.ifi_link_state != LINK_STATE_DOWN)
+#endif
     f.flags |= IF_LINK_UP;          /* up or unknown */
   if (fl & IFF_LOOPBACK)            /* Loopback */
     f.flags |= IF_MULTIACCESS | IF_LOOPBACK | IF_IGNORE;
@@ -873,9 +877,11 @@ krt_read_msg(struct proto *p, struct ks_msg *msg, int scan)
     case RTM_CHANGE:
       krt_read_route(msg, (struct krt_proto *)p, scan);
       break;
+#ifndef __APPLE__
     case RTM_IFANNOUNCE:
       krt_read_ifannounce(msg);
       break;
+#endif
     case RTM_IFINFO:
       krt_read_ifinfo(msg, scan);
       break;
diff --git a/sysdep/bsd/sysio.h b/sysdep/bsd/sysio.h
index b6b42b1e..85081c07 100644
--- a/sysdep/bsd/sysio.h
+++ b/sysdep/bsd/sysio.h
@@ -32,7 +32,7 @@
 #endif
 
 
-#ifdef __NetBSD__
+#if defined(__NetBSD__) || defined(__APPLE__)
 
 #ifndef IP_RECVTTL
 #define IP_RECVTTL 23
@@ -49,6 +49,10 @@
 #define TCP_MD5SIG	TCP_SIGNATURE_ENABLE
 #endif
 
+#ifdef __APPLE__
+#define TCP_MD5SIG	TCPOPT_SIGNATURE
+#endif
+
 
 #undef  SA_LEN
 #define SA_LEN(x) (x).sa.sa_len
diff --git a/sysdep/unix/io.c b/sysdep/unix/io.c
index 9b499020..81e09888 100644
--- a/sysdep/unix/io.c
+++ b/sysdep/unix/io.c
@@ -12,6 +12,9 @@
 #ifndef _GNU_SOURCE
 #define _GNU_SOURCE
 #endif
+#ifdef __APPLE__
+#define __APPLE_USE_RFC_3542
+#endif
 
 #include <stdio.h>
 #include <stdlib.h>
diff --git a/sysdep/unix/random.c b/sysdep/unix/random.c
index 4e64e56b..7d68c482 100644
--- a/sysdep/unix/random.c
+++ b/sysdep/unix/random.c
@@ -16,7 +16,7 @@
 #include "sysdep/config.h"
 #include "nest/bird.h"
 
-#ifdef HAVE_GETRANDOM
+#if defined(HAVE_GETRANDOM) || (defined(__APPLE__) && defined(HAVE_GETENTROPY))
 #include <sys/random.h>
 #endif

