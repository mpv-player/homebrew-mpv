require "formula"

class Mvtools < Formula
  desc "Filters for motion estimation and compensation"
  url "https://github.com/dubhater/vapoursynth-mvtools/archive/v9.tar.gz"
  homepage "https://github.com/dubhater/vapoursynth-mvtools"
  head "https://github.com/dubhater/vapoursynth-mvtools.git"
  sha256 "e417764cddcc2b24ee5a91c1136e95237ce1424f5d7f49ceb62ff092db18d907"

  depends_on "pkg-config" => :build
  depends_on "yasm" => :build
  depends_on "vapoursynth"
  depends_on "fftw"
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
