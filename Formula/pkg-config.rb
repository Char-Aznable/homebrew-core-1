class PkgConfig < Formula
  desc "Manage compile and link flags for libraries"
  homepage "https://freedesktop.org/wiki/Software/pkg-config/"
  url "https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
  mirror "https://dl.bintray.com/homebrew/mirror/pkg-config-0.29.2.tar.gz"
  sha256 "6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591"
  revision 1 unless OS.mac?

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "c0a6927c8e404f6db8b14d6644a218b22ddb0d27be1fa0a69d15bf0d9a6875ae" => :catalina
    sha256 "dcfcba723621eee085ddd5ebadc41fb8787a4717b9686f5288281633a830ac5e" => :mojave
    sha256 "b6c0b7344ea89558f5d98711625e00414dc2be53af23c9ee8fcb07554f1736ac" => :high_sierra
    sha256 "9fb8d825733b80b304c5bbf6b6d795a0991eaed1a0aac7b4bf453a144e178bd5" => :x86_64_linux
  end

  def install
    pc_path = %W[
      #{HOMEBREW_PREFIX}/lib/pkgconfig
      #{HOMEBREW_PREFIX}/share/pkgconfig
    ]
    if OS.mac?
      pc_path += %W[/usr/local/lib/pkgconfig /usr/lib/pkgconfig #{HOMEBREW_LIBRARY}/Homebrew/os/mac/pkgconfig/#{MacOS.version}"]
    else
      pc_path << "#{HOMEBREW_LIBRARY}/Homebrew/os/linux/pkgconfig"
    end

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--disable-host-tool",
                          "--with-internal-glib",
                          "--with-pc-path=#{pc_path.join(File::PATH_SEPARATOR)}"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    assert_match "#{HOMEBREW_PREFIX}/lib/pkgconfig:", shell_output("#{bin}/pkg-config pkg-config --variable pc_path")
    system "#{bin}/pkg-config", "--libs", "libpcre" if OS.mac?
  end
end
