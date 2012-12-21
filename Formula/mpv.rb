require 'formula'

def libav?
  build.include? 'with-libav'
end

class DocutilsInstalled < Requirement
  def message; <<-EOS.undent
    Docutils is required to install.

    You can install this with:
      sudo easy_install docutils
    EOS
  end

  def satisfied?
    which('rst2man') || which('rst2man.py')
  end

  def fatal?
    true
  end
end

class Mpv < Formula
  head 'git://github.com/mpv-player/mpv.git', :using => :git
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'pkg-config' => :build
  depends_on DocutilsInstalled.new => :build

  depends_on 'libbs2b'
  depends_on 'libass'
  depends_on 'mpg123'
  depends_on 'libdvdread'
  depends_on 'libquvi'

  if libav?
    depends_on 'mpv-player/mpv/libav'
  else
    depends_on 'ffmpeg'
  end

  env :std # looks like :superenv doesn't pick up Dockutils path

  unless libav?
    def caveats; <<-EOS.undent
      mpv is designed to work better with HEAD versions of ffmpeg/libav.
      If you are noticing problems please try to install the HEAD version of
      ffmpeg with: `brew install --HEAD ffmpeg`
      EOS
    end
  end

  option 'with-libav', 'Build against libav instead of ffmpeg.'

  def install
    ENV.O1 if ENV.compiler == :llvm

    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}",
            "--enable-macosx-bundle",
            "--enable-macosx-finder",
            "--enable-apple-remote"]

    generate_version
    system "./configure", *args
    system "make install"
  end

  private
  def generate_version
    ohai "Generating VERSION from the Homebrew's git cache"
    File.open('VERSION', 'w') {|f| f.write(git_revision) }
  end

  def git_revision
    `cd #{git_cache} && git describe --match "v[0-9]*" --always`.strip
  end

  def git_cache
    @downloader.cached_location
  end
end
