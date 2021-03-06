class Healpix < Formula
  desc "Hierarchical Equal Area isoLatitude Pixelization of a sphere"
  homepage "https://healpix.jpl.nasa.gov"
  url "https://downloads.sourceforge.net/project/healpix/Healpix_3.50/Healpix_3.50_2018Dec10.tar.gz"
  version "3.50"
  sha256 "ec9378888ef8365f9a83fa82e3ef3b4e411ed6a63aca33b74a6917c05334bf4f"

  bottle do
    cellar :any
    sha256 "bbdffcc18f74787a48b54de7f3670515f7f2291feaf9b5e03ac2cdb6cbec6381" => :catalina
    sha256 "7d494b528ed28e6df329d22ba3d14e307b5e7c897af3f2219c30bffbf638c956" => :mojave
    sha256 "76f44151520341f299560a7836b743bf5285f6e900c5ee8bb69f69777875740e" => :high_sierra
    sha256 "dd1261e0aedf5b2b180011999223b14edda14564c73a274af75642c4073e330a" => :sierra
    sha256 "60fcc4b3a551a2f24a8f5c23d82b509cb4fa21c11d47ad01ad6207425cec1dbc" => :x86_64_linux
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "cfitsio"

  def install
    configure_args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
    ]

    cd "src/C/autotools" do
      system "autoreconf", "--install"
      system "./configure", *configure_args
      system "make", "install"
    end

    cd "src/cxx/autotools" do
      system "autoreconf", "--install"
      system "./configure", *configure_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cxx").write <<-EOS
      #include <math.h>
      #include <stdio.h>
      #include "chealpix.h"
      int main(void) {
        long nside, npix, pp, ns1;
        nside = 1024;
        for (pp = 0; pp < 14; pp++) {
          nside = pow(2, pp);
          npix = nside2npix(nside);
          ns1  = npix2nside(npix);
        }
      };
    EOS

    system ENV.cxx, "-o", "test", "test.cxx", "-L#{lib}", "-lchealpix"
    system "./test"
  end
end
