require "formula"

class Mvtools < Formula
  url "https://github.com/dubhater/vapoursynth-mvtools/archive/v9.tar.gz"
  homepage "https://github.com/dubhater/vapoursynth-mvtools"
  head "https://github.com/dubhater/vapoursynth-mvtools.git"

  depends_on "pkg-config" => :build
  depends_on "yasm" => :build
  depends_on "vapoursynth"
  depends_on "fftw"

  if build.head?
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
