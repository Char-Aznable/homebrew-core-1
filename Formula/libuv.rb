class Libuv < Formula
  desc "Multi-platform support library with a focus on asynchronous I/O"
  homepage "https://github.com/libuv/libuv"
  url "https://github.com/libuv/libuv/archive/v1.31.0.tar.gz"
  sha256 "ab041ea5d1965a33d4e03ea87718b8922ba4e54abb46c71cf9e040edef2556c0"
  head "https://github.com/libuv/libuv.git", :branch => "v1.x"

  bottle do
    cellar :any
    sha256 "3202b80f4a93cedcc30ed1193c192e9cf6ebfdf9db41347ff8e9690a05ea6e45" => :catalina
    sha256 "d99c68a335354839700616c87cdfea6635025965be5728a974ec866838d403ae" => :mojave
    sha256 "d0afcf32eac5aeb43fbc8711a590127d1cb54343f85ade53c7bb0083608041f4" => :high_sierra
    sha256 "e86931a805793e222336c213a45c2fd0633123271ebaa3b69995053fe4803d15" => :sierra
    sha256 "a46232d23c949f7a6672484ac2d6640744cfc388960254edfb1762e554ae68b1" => :x86_64_linux
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "sphinx-doc" => :build

  def install
    # This isn't yet handled by the make install process sadly.
    cd "docs" do
      system "make", "man"
      system "make", "singlehtml"
      man1.install "build/man/libuv.1"
      doc.install Dir["build/singlehtml/*"]
    end

    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <uv.h>
      #include <stdlib.h>

      int main()
      {
        uv_loop_t* loop = malloc(sizeof *loop);
        uv_loop_init(loop);
        uv_loop_close(loop);
        free(loop);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-luv", "-o", "test"
    system "./test"
  end
end
