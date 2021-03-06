class Vte < Formula
  desc "Terminal emulator widget used by GNOME terminal"
  homepage "https://developer.gnome.org/vte/"
  url "https://download.gnome.org/sources/vte/0.28/vte-0.28.2.tar.xz"
  sha256 "86cf0b81aa023fa93ed415653d51c96767f20b2d7334c893caba71e42654b0ae"
  revision 4

  bottle do
    rebuild 1
    sha256 "26d7503f02898f3b188f3c9eb3bf843feaccc0d6694a9f360f1e6e3ea0e10bd1" => :catalina
    sha256 "320ff58d9e751660a0f6feea056915df5b1266d43ee4223e4622bc07da0dcf24" => :mojave
    sha256 "f8ed141e63dea2c9bbb68e974571a574bda1330d32575c10c792de5e0ea4ffea" => :high_sierra
    sha256 "f84c4aa751a6c63962cc8c1a30cd1fcc3938652b259f51e252b20763fe4a9ef8" => :sierra
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "glib"
  depends_on "gtk+"
  depends_on "pygobject"
  depends_on "pygtk"
  depends_on "python@2"

  def install
    # Needed by intltool (xml::parser)
    ENV.prepend_path "PERL5LIB", "#{Formula["intltool"].libexec}/lib/perl5" unless OS.mac?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-Bsymbolic
      --enable-python
    ]

    # pygtk-codegen-2.0 has been deprecated and replaced by
    # pygobject-codegen-2.0, but the vte Makefile does not detect this.
    ENV["PYGTK_CODEGEN"] = Formula["pygobject"].bin/"pygobject-codegen-2.0"

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <vte/vte.h>

      int main(int argc, char *argv[]) {
        char *rv = vte_get_user_shell();
        return 0;
      }
    EOS
    atk = Formula["atk"]
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gdk_pixbuf = Formula["gdk-pixbuf"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    gtkx = Formula["gtk+"]
    harfbuzz = Formula["harfbuzz"]
    libpng = Formula["libpng"]
    pango = Formula["pango"]
    pixman = Formula["pixman"]
    backend = OS.mac? ? "quartz" : "x11"
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{atk.opt_include}/atk-1.0
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gdk_pixbuf.opt_include}/gdk-pixbuf-2.0
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/gio-unix-2.0/
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{gtkx.opt_include}/gtk-2.0
      -I#{gtkx.opt_lib}/gtk-2.0/include
      -I#{harfbuzz.opt_include}/harfbuzz
      -I#{include}/vte-0.0
      -I#{libpng.opt_include}/libpng16
      -I#{pango.opt_include}/pango-1.0
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{atk.opt_lib}
      -L#{cairo.opt_lib}
      -L#{gdk_pixbuf.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{gtkx.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -latk-1.0
      -lcairo
      -lgdk-#{backend}-2.0
      -lgdk_pixbuf-2.0
      -lgio-2.0
      -lglib-2.0
      -lgobject-2.0
      -lgtk-#{backend}-2.0
      -lpango-1.0
      -lpangocairo-1.0
      -lvte
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
