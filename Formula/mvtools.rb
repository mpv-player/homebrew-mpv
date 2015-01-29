require "formula"

class Mvtools < Formula
  homepage "https://github.com/dubhater/vapoursynth-mvtools"
  head     "https://github.com/dubhater/vapoursynth-mvtools.git"

  depends_on 'pkg-config' => :build
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build
  depends_on 'yasm' => :build
  depends_on 'vapoursynth'
  depends_on 'fftw'

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end
end
