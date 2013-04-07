require 'formula'

def libav?
  build.include? 'with-libav'
end

def x11?
  build.include? 'with-x11'
end

def bundle?
  not build.include? 'without-bundle'
end

def jack?
  build.include? 'with-jack'
end

class DocutilsInstalled < Requirement
  fatal true
  env :userpaths

  def message; <<-EOS.undent
    Docutils is required to install.

    You can install this with:
      [sudo] easy_install pip
      pip install docutils
    EOS
  end

  def satisfied?
    which('rst2man') || which('rst2man.py')
  end
end

class GitVersionWriter
  def initialize(downloader)
    @downloader = downloader
  end

  def write
    ohai "Generating VERSION file from Homebrew's git cache"
    File.open('VERSION', 'w') {|f| f.write(git_revision) }
  end

  private
  def git_revision
    `cd #{git_cache} && git describe --match "v[0-9]*" --always`.strip
  end

  def git_cache
    @downloader.cached_location
  end
end

class Mpv < Formula
  head 'https://github.com/mpv-player/mpv.git', :using => :git
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'pkg-config' => :build
  depends_on DocutilsInstalled.new => :build

  depends_on 'libbs2b'
  depends_on 'libass'
  depends_on 'mpg123'
  depends_on 'libdvdread'
  depends_on 'libquvi'
  depends_on 'little-cms2'
  depends_on 'jpeg'

  if libav?
    depends_on 'mpv-player/mpv/libav'
  else
    depends_on 'ffmpeg'
  end

  depends_on :x11 if x11?

  def caveats
    cvts = <<-EOS.undent
      mpv is designed to work better with HEAD versions of ffmpeg/libav.
      If you are noticing problems please try to install the HEAD version of
      ffmpeg with: `brew install --HEAD ffmpeg`
      EOS
    cvts << bundle_caveats if bundle?
    cvts
  end

  option 'with-libav',     'Build against libav instead of ffmpeg.'
  option 'with-x11',       'Build with X11 backend support.'
  option 'with-jack',      'Build with support for JackOSX (jackosx.com).'
  option 'without-bundle', 'Do not create a Mac OSX Application Bundle.'

  def install
    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}"]

    args << "--enable-macosx-bundle" if bundle?
    args << "--enable-macosx-finder" if bundle?
    args << "--enable-jack" if jack?
    args << "--disable-x11" unless x11?

    GitVersionWriter.new(@downloader).write
    system "./configure", *args
    system "make install"

    if bundle?
      system "make osxbundle"
      prefix.install "mpv.app"
    end
  end

  private
  def bundle_caveats; <<-EOS.undent

      mpv.app installed to:
        #{prefix}

      To link the application to a normal Mac OS X location:
          brew linkapps
      or:
          ln -s #{prefix}/mpv.app /Applications
      EOS
  end
end
