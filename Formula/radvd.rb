class Radvd < Formula
  desc "IPv6 Router Advertisement Daemon"
  homepage "https://radvd.litech.org/"
  url "https://github.com/radvd-project/radvd/releases/download/v2.19/radvd-2.19.tar.xz"
  sha256 "564e04597f71a9057d02290da0dd21b592d277ceb0e7277550991d788213e240"
  license "NOASSERTION"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest
  end

  head do
    url "https://github.com/radvd-project/radvd.git", branch: "master"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  uses_from_macos "bison" => :build

  def install
    system "./autogen.sh" if build.head?
    system "./configure", *std_configure_args, "--disable-silent-rules"
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
