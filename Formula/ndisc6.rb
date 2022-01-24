class Ndisc6 < Formula
  desc "IPv6 diagnostic tools for Linux and BSD"
  homepage "https://www.remlab.net/ndisc6/"
  url "https://www.remlab.net/files/ndisc6/ndisc6-1.0.5.tar.bz2"
  sha256 "36932f9fc47e2844abcda7550fa1343b3af4b4208dfb61e0c9d9224aad5df351"
  license "GPL-2.0-or-later"

  livecheck do
    url "https://www.remlab.net/files/ndisc6"
    regex(/href=.*?ndisc6[._-]?v?(\d+(?:\.\d+)+)\.t/i)
  end

  head do
    url "https://git.remlab.net/git/ndisc6.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "gettext"
  patch :DATA

  def install
    system "./autogen.sh" if build.head?
    if build.head?
      Pathname("include/gettext.h").write <<~EOS
        #include <libintl.h>
        #undef N_
        #define N_(str) (str)
      EOS
    end
    ENV["LIBS"] = "-lintl"
    system "./configure", *std_configure_args, "--disable-silent-rules"
    system "make", "install"
  end

  test do
    system bin/"ndisc6", "-V"
  end
end

__END__
diff --git a/rdnss/icmp.c b/rdnss/icmp.c
index f85798d..4f9f966 100644
--- a/rdnss/icmp.c
+++ b/rdnss/icmp.c
@@ -22,6 +22,7 @@
 #endif
 
 #include <stdint.h>
+#include <string.h>
 
 #include <sys/types.h>
 #include <sys/socket.h>
diff --git a/rdnss/rdnssd.h b/rdnss/rdnssd.h
index 3def220..68668a6 100644
--- a/rdnss/rdnssd.h
+++ b/rdnss/rdnssd.h
@@ -32,23 +32,6 @@ extern const rdnss_src_t rdnss_netlink, rdnss_icmp;
 #define ND_OPT_RDNSS 25
 #define ND_OPT_DNSSL 31
 
-struct nd_opt_rdnss
-{
-	uint8_t nd_opt_rdnss_type;
-	uint8_t nd_opt_rdnss_len;
-	uint16_t nd_opt_rdnss_reserved;
-	uint32_t nd_opt_rdnss_lifetime;
-	/* followed by one or more IPv6 addresses */
-};
-
-struct nd_opt_dnssl
-{
-	uint8_t nd_opt_dnssl_type;
-	uint8_t nd_opt_dnssl_len;
-	uint16_t nd_opt_dnssl_reserved;
-	uint32_t nd_opt_dnssl_lifetime;
-	/* followed by one or more domain names */
-};
 
 # ifdef __cplusplus
 extern "C" {
diff --git a/src/gettime.h b/src/gettime.h
index 3276ab1..85f4fa9 100644
--- a/src/gettime.h
+++ b/src/gettime.h
@@ -41,6 +41,9 @@ static inline int mono_nanosleep (const struct timespec *ts)
 {
 	int rc;
 
+#ifdef __APPLE__
+    rc = nanosleep(ts, NULL);
+#else
 #if (_POSIX_MONOTONIC_CLOCK >= 0)
 	rc = clock_nanosleep (CLOCK_MONOTONIC, 0, ts, NULL);
 #endif
@@ -49,6 +52,7 @@ static inline int mono_nanosleep (const struct timespec *ts)
 #endif
 #if (_POSIX_MONOTONIC_CLOCK <= 0)
 		rc = clock_nanosleep (CLOCK_REALTIME, 0, ts, NULL);
+#endif
 #endif
 	return rc;
 }
