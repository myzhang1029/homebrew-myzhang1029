class Ndisc6 < Formula
  desc "IPv6 diagnostic tools for Linux and BSD"
  homepage "https://www.remlab.net/ndisc6/"
  url "https://www.remlab.net/files/ndisc6/ndisc6-1.0.8.tar.bz2"
  sha256 "1f2fb2dc1172770aa5a09d39738a44d8b753cc5e2e25e306ca78682f9fea0b4f"
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
    system bin/"addr2name", "--version"
    system bin/"name2addr", "--version"
    system bin/"ndisc6", "--version"
    system bin/"rdisc6", "--version"
    system bin/"rltraceroute6", "--version"
    system bin/"tcpspray", "--version"
    system bin/"tcpspray6", "--version"
    system bin/"tcptraceroute6", "--version"
    system bin/"tracert6", "--version"
    system sbin/"rdnssd", "--version"
  end
end

__END__
diff --git a/rdnss/rdnssd.h b/rdnss/rdnssd.h
index 3def220..bbbda79 100644
--- a/rdnss/rdnssd.h
+++ b/rdnss/rdnssd.h
@@ -32,6 +32,7 @@ extern const rdnss_src_t rdnss_netlink, rdnss_icmp;
 #define ND_OPT_RDNSS 25
 #define ND_OPT_DNSSL 31
 
+#ifndef __APPLE__
 struct nd_opt_rdnss
 {
        uint8_t nd_opt_rdnss_type;
@@ -49,6 +50,7 @@ struct nd_opt_dnssl
        uint32_t nd_opt_dnssl_lifetime;
        /* followed by one or more domain names */
 };
+#endif
 
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
diff --git a/src/ndisc.c b/src/ndisc.c
index b190b18..93767e0 100644
--- a/src/ndisc.c
+++ b/src/ndisc.c
@@ -74,6 +74,12 @@
 # define AI_IDN 0
 #endif
 
+#ifndef s6_addr32
+# if defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__APPLE__)|| defined(__DragonFly__)
+#  define s6_addr32 __u6_addr.__u6_addr32
+# endif
+#endif
+
 
 enum ndisc_flags
 {
