class Radvd < Formula
  desc "IPv6 Router Advertisement Daemon"
  homepage "https://radvd.litech.org/"
  url "https://github.com/radvd-project/radvd/releases/download/v2.20/radvd-2.20.tar.xz"
  sha256 "25d2960fb977ac35c45a8d85b71db22ed8af325db7dbf4a562fb03eab2848dcd"
  license "radvd"

  head do
    url "https://github.com/radvd-project/radvd.git", branch: "master"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "pkgconf" => :build
  depends_on "libbsd"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-silent-rules", *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"radvd.conf").write <<~EOS
      # Example config
      interface lo
      {
          AdvSendAdvert on;
          IgnoreIfMissing on;
          MinRtrAdvInterval 3;
          MaxRtrAdvInterval 10;
          AdvDefaultPreference low;
          AdvHomeAgentFlag off;
          prefix 2001:db8:1:0::/64
          {
              AdvOnLink on;
              AdvAutonomous on;
              AdvRouterAddr off;
          };
          prefix 0:0:0:1234::/64
          {
              AdvOnLink on;
              AdvAutonomous on;
              AdvRouterAddr off;
              Base6to4Interface ppp0;
              AdvPreferredLifetime 120;
              AdvValidLifetime 300;
          };
          route 2001:db0:fff::/48
          {
              AdvRoutePreference high;
              AdvRouteLifetime 3600;
          };
          RDNSS 2001:db8::1 2001:db8::2
          {
              AdvRDNSSLifetime 30;
          };
          DNSSL branch.example.com example.com
          {
              AdvDNSSLLifetime 30;
          };
      };
    EOS
    system sbin/"radvd", "-cC", testpath/"radvd.conf"
  end
end
