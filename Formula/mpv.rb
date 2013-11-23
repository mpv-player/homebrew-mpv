require 'formula'

class JackOSX < Requirement
  fatal true

  env do
    ENV.append 'CFLAGS',  '-I/usr/local/include'
    ENV.append 'LDFLAGS', '-L/usr/local/lib -ljack -framework CoreAudio -framework CoreServices -framework AudioUnit'
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
    `cd #{git_cache} && ./version.sh --print`.strip
  end

  def git_cache
    @downloader.cached_location
  end
end

class Mpv < Formula
  url 'https://github.com/mpv-player/mpv/archive/v0.2.3.tar.gz'
  sha1 'b8ad4fdde916cbb00ebc1aa7371b30ccf48a777c'
  head 'https://github.com/mpv-player/mpv.git'
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'mpv-player/mpv/waf' => :build
  depends_on 'pkg-config' => :build
  depends_on DocutilsInstalled.new => :build

  option 'with-official-libass', 'Use official version of libass (instead of experimental CoreText based branch)'
  option 'with-libav',           'Build against libav instead of ffmpeg.'
  option 'with-bundle',          'Create a Mac OSX Application Bundle alongside the CLI version of mpv.'
  option 'with-jackosx',         'Build with jackosx support.'

  if build.with? 'official-libass'
    depends_on 'libass'
  else
    depends_on 'mpv-player/mpv/libass-ct'
  end

  if build.with? 'libav'
    depends_on 'libav'
  else
    depends_on 'ffmpeg'
  end

  depends_on 'mpg123'      => :recommended
  depends_on 'jpeg'        => :recommended

  depends_on 'libcaca'     => :optional
  depends_on 'libbs2b'     => :optional
  depends_on 'libquvi'     => :optional
  depends_on 'libdvdread'  => :optional
  depends_on 'little-cms2' => :optional
  depends_on 'lua'         => :optional
  depends_on 'libbluray'   => :optional
  depends_on 'libaacs'     => :optional
  depends_on :x11          => :optional

  depends_on JackOSX.new if build.with? 'jackosx'

  def caveats
    if build.with?('bundle')
      ffmpeg_caveats + bundle_caveats
    else
      ffmpeg_caveats
    end
  end

  def install
    args = ["--prefix=#{prefix}", "--disable-sdl"]
    args << "--disable-x11" unless build.with? 'x11'
    args << "--enable-jack" if build.with? 'jackosx'
    args << "--enable-macosx-bundle" if build.with? 'bundle' and build.head?

    GitVersionWriter.new(@downloader).write if build.head?

    if build.head?
      system "waf", "configure", *args
      system "waf", "install"
    else
      system "./configure", *args
      system "make install"
    end

    if build.with? 'bundle' and not build.head?
      system "make osxbundle-skip-deps"
      prefix.install "mpv.app"
    end
  end

  private
  def ffmpeg_caveats; <<-EOS.undent
      mpv requires an up to date version of ffmpeg to have complete features.
      Unfortunately the homebrew team wants to keep support for shitty software
      that depends on ffmpeg oldstable (1.2). This prevents mpv from activating
      some features like VDA and many others.

      If this is important to you I suggest you complain to the homebrew team
      or install ffmpeg with `brew install --HEAD ffmpeg`.
    EOS
  end

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
