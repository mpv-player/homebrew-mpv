require 'formula'

class JackOSX < Requirement
  fatal true

  env do
    ENV.append 'LDFLAGS', "-ljack"
  end

  def satisfied?
    which('jackd')
  end
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
  url 'https://github.com/mpv-player/mpv/archive/v0.2.0.tar.gz'
  sha1 'c61c9ed56196ad0ad77460a0e18f17d39638a539'
  head 'https://github.com/mpv-player/mpv.git', :using => :git
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'pkg-config' => :build
  depends_on DocutilsInstalled.new => :build

  depends_on 'libass'      => :recommended
  depends_on 'mpg123'      => :recommended
  depends_on 'jpeg'        => :recommended

  depends_on 'libcaca'     => :optional
  depends_on 'libbs2b'     => :optional
  depends_on 'libquvi'     => :optional
  depends_on 'libdvdread'  => :optional
  depends_on 'little-cms2' => :optional
  depends_on 'lua'         => :optional
  depends_on JackOSX.new   => :optional if build.with? 'jack'

  depends_on 'libbluray' if build.with? 'bluray-support'
  depends_on 'libaacs'   if build.with? 'bluray-support'

  if build.with? 'libav'
    depends_on 'mpv-player/mpv/libav'
  else
    depends_on 'ffmpeg'
  end

  depends_on :x11 => :optional

  def caveats
    cvts = <<-EOS.undent
      mpv is designed to work better with HEAD versions of ffmpeg/libav.
      If you are noticing problems please try to install the HEAD version of
      ffmpeg with: `brew install --HEAD ffmpeg`
      EOS
    cvts << bundle_caveats if build.with? 'bundle'
    cvts
  end

  option 'without-libass',      'Build without libass.'
  option 'with-libav',          'Build against libav instead of ffmpeg.'
  option 'with-libbs2b',        'Build with libbs2b support (stereophonic-to-binaural filter).'
  option 'with-libcaca',        'Build with libcaca support (ASCII-art video output).'
  option 'with-libquvi',        'Build with libquvi support (watch videos from YouTube and other websites).'
  option 'with-x11',            'Build with X11 windowing support.'
  option 'with-jack',           'Build with support for JackOSX (jackosx.com).'
  option 'with-little-cms2',    'Build with little-cms2 support (Color management for OpenGL video outputs).'
  option 'with-lua',            'Build with lua support (Scripting, On-Screen Controller).'
  option 'with-bluray-support', 'Build with Bluray support (libbluray + libaacs).'
  option 'without-bundle',      'Do not create a Mac OSX Application Bundle.'

  def install
    args = ["--prefix=#{prefix}",
            "--disable-sdl",
            "--cc=#{ENV.cc}"]

    args << "--disable-x11" unless build.with? 'x11'
    args << "--disable-libass" if build.without? 'libass'

    GitVersionWriter.new(@downloader).write if build.head?

    system "./configure", *args
    system "make install"

    if build.with? 'bundle'
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
