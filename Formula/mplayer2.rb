require 'formula'

class Mplayer2 <Formula
  head 'git://git.mplayer2.org/mplayer2.git', :using => :git
  homepage 'http://mplayer2.org'

  depends_on 'pkg-config' => :build
  depends_on 'libbs2b' => :build
  depends_on 'libass' => :build
  depends_on 'pigoz/mplayer2/freetype' => :build
  depends_on 'pigoz/mplayer2/libav' => :build

  def install
    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}",
            "--enable-macosx-bundle",
            "--enable-macosx-finder",
            "--enable-apple-remote"]

    system "./configure", *args
    system "make install"

    # change the binary name to mplayer2
    FileUtils.mv(bin + 'mplayer', bin + 'mplayer2')
  end
end
