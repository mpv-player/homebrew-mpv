require 'formula'

class LibassGit < Formula
  homepage 'https://github.com/libass/libass'
  head 'https://github.com/libass/libass.git'

  depends_on 'pkg-config' => :build
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libtool' => :build
  depends_on 'yasm' => :build

  depends_on :freetype
  depends_on 'fribidi'
  depends_on 'harfbuzz'

  keg_only <<-TEXT.undent
    This is a drop in replacement of homebrew's libass. It uses the same
    pkg-config package name: it's better not to install it to avoid breaking
    other packages in homebrew.
  TEXT

  def install
    system "autoreconf -i"
    system "./configure", "--disable-dependency-tracking",
                          "--disable-fontconfig",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
