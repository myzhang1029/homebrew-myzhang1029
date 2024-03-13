class CnRoutefeed < Formula
  desc "BGP speaker that feeds all China IPv4 delegations to peer"
  homepage "https://github.com/Nat-Lab/cn-routefeed"
  url "https://github.com/Nat-Lab/cn-routefeed/archive/refs/heads/master.tar.gz"
  version "latest"
  sha256 "75aa97c4935b48c977b835c12bb4d5be41017839adf4f01bc7deaef16b3eea2d"
  license "Unlicense"

  depends_on "cmake" => :build
  depends_on "curl"
  depends_on "libbgp"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    system "false"
  end
end
