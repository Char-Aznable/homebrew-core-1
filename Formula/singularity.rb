class Singularity < Formula
  desc "Application containers for Linux"
  homepage "https://www.sylabs.io/singularity/"
  url "https://github.com/sylabs/singularity/releases/download/v3.3.0/singularity-3.3.0.tar.gz"
  sha256 "070530a472e7e78492f1f142c8d4b77c64de4626c4973b0589f0d18e1fcf5b4f"
  revision 1
  # tag "linux"

  bottle do
    cellar :any_skip_relocation
    sha256 "9749352d720adb36d5121fa9631af9a0b39a49e2c4b98875c691d23596c0cf6c" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "openssl@1.1" => :build
  depends_on "libarchive"
  depends_on "pkg-config"
  depends_on "squashfs"
  depends_on "util-linux" # for libuuid

  def install
    system "./mconfig", "--prefix=#{prefix}"
    cd "./builddir" do
      system "make"
      system "make", "install"
    end
  end

  test do
    assert_match "Usage", shell_output("#{bin}/singularity --help")
  end
end
