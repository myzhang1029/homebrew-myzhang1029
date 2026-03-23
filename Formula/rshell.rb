class Rshell < Formula
  include Language::Python::Virtualenv

  desc "Remote Shell for MicroPython"
  homepage "https://github.com/dhylands/rshell"
  url "https://github.com/dhylands/rshell/archive/refs/tags/v0.0.32.tar.gz"
  sha256 "faac6d0636bea81af8b95e55517a2ff59bb513c96b40e1f1ae0485c3662b9043"
  license "MIT"

  depends_on "python@3.14"

  resource "pyserial" do
    url "https://files.pythonhosted.org/packages/1e/7d/ae3f0a63f41e4d2f6cb66a5b57197850f919f59e558159a4dd3a818f5082/pyserial-3.5.tar.gz"
    sha256 "3c77e014170dfffbd816e6ffc205e9842efb10be9f58ec16d3e8675b4925cddb"
  end

  resource "pyudev" do
    url "https://files.pythonhosted.org/packages/5e/1d/8bdbf651de1002e8b58fbe817bee22b1e8bfcdd24341d42c3238ce9a75f4/pyudev-0.24.4.tar.gz"
    sha256 "e788bb983700b1a84efc2e88862b0a51af2a995d5b86bc9997546505cf7b36bc"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    system bin/"rshell", "--help"
  end
end
