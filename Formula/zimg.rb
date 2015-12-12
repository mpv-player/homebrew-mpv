require "formula"

class Zimg < Formula
  url "https://github.com/sekrit-twc/zimg/archive/release-2.0.2.tar.gz"
  sha265 "b9c7bac9e6ad53dfa94215c28440167d72d41109df10278673789f8e531f2142"
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
