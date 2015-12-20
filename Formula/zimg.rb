require "formula"

class Zimg < Formula
  desc "Scaling, colorspace conversion, and dithering library"
  url "https://github.com/sekrit-twc/zimg/archive/release-2.0.2.tar.gz"
  sha1 "3d44f026fa294e0d0dab6d85d6ef515d172ab26c"
  homepage "https://github.com/sekrit-twc/zimg"

  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
