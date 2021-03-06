class Sip < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/4.19.19/sip-4.19.19.tar.gz"
  sha256 "5436b61a78f48c7e8078e93a6b59453ad33780f80c644e5f3af39f94be1ede44"
  revision 3
  head "https://www.riverbankcomputing.com/hg/sip", :using => :hg

  bottle do
    cellar :any_skip_relocation
    sha256 "55d3dbbc80a7d87d4c4c4e0644e473edfbfc6ea8c00f96b745c788ed0de16114" => :catalina
    sha256 "52c3ab51c8754323ef8219e84235214c5cf1f12e6c704d5fe70b2b95372f306e" => :mojave
    sha256 "3e037042028c83b9329d376ed6663ddfe7ba90f714cc623421ed8ff2e87f90b5" => :high_sierra
    sha256 "66420e12ef8e5a1fee2a528dc8cf12bc188236da8bb06365b9e1cce9cc3d56f3" => :x86_64_linux
  end

  depends_on "python"

  def install
    ENV.prepend_path "PATH", Formula["python"].opt_libexec/"bin"
    ENV.delete("SDKROOT") # Avoid picking up /Application/Xcode.app paths

    if build.head?
      # Link the Mercurial repository into the download directory so
      # build.py can use it to figure out a version number.
      ln_s cached_download/".hg", ".hg"
      # build.py doesn't run with python3
      system "python", "build.py", "prepare"
    end

    version = Language::Python.major_minor_version "python3"
    system "python3", "configure.py",
                     *("--deployment-target=#{MacOS.version}" if OS.mac?),
                      "--destdir=#{lib}/python#{version}/site-packages",
                      "--bindir=#{bin}",
                      "--incdir=#{include}",
                      "--sipdir=#{HOMEBREW_PREFIX}/share/sip",
                      "--sip-module", "PyQt5.sip"
    system "make"
    system "make", "install"
  end

  def post_install
    (HOMEBREW_PREFIX/"share/sip").mkpath
  end

  test do
    (testpath/"test.h").write <<~EOS
      #pragma once
      class Test {
      public:
        Test();
        void test();
      };
    EOS
    (testpath/"test.cpp").write <<~EOS
      #include "test.h"
      #include <iostream>
      Test::Test() {}
      void Test::test()
      {
        std::cout << "Hello World!" << std::endl;
      }
    EOS
    (testpath/"test.sip").write <<~EOS
      %Module test
      class Test {
      %TypeHeaderCode
      #include "test.h"
      %End
      public:
        Test();
        void test();
      };
    EOS
    if OS.mac?
      system ENV.cxx, "-shared", "-Wl,-install_name,#{testpath}/libtest.dylib",
                    "-o", "libtest.dylib", "test.cpp"
    else
      system ENV.cxx, "-fPIC", "-shared", "-Wl,-soname,#{testpath}/libtest.so",
                    "-o", "libtest.so", "test.cpp"
    end
    system bin/"sip", "-b", "test.build", "-c", ".", "test.sip"
  end
end
