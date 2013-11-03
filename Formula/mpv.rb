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
  url 'https://github.com/mpv-player/mpv/archive/v0.2.2.tar.gz'
  sha1 '3a86a5fe84ef69d61a3681e975b75406a536df89'
  head 'https://github.com/mpv-player/mpv.git', :using => :git
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'pkg-config' => :build
  depends_on DocutilsInstalled.new => :build

  option 'with-official-libass', 'Use official version of libass (instead of experimental CoreText based branch)'
  option 'with-libav',           'Build against libav instead of ffmpeg.'
  option 'with-bundle',          'Create a Mac OSX Application Bundle alongside the CLI version of mpv.'
  option 'with-dist-bundle',     'Create a Mac OSX Application Bundle alongside the CLI version of mpv (distributable version).'
  option 'with-jackosx',         'Build with jackosx support.'

  if build.with? 'official-libass'
    depends_on 'libass'
  else
    depends_on 'mpv-player/mpv/libass-ct'
    # for testing
    # depends_on File.expand_path('../libass-ct', __FILE__)
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
    if build.with? 'bundle'
      bundle_caveats
    else
      super
    end
  end

  def install
    if build.with? 'bundle' and build.with? 'dist-bundle'
      raise '--with-bundle, --with-dist-bundle: make up your mind and choose one'
    end

    args = ["--prefix=#{prefix}",
            "--disable-sdl",
            "--cc=#{ENV.cc}"]

    args << "--disable-x11" unless build.with? 'x11'
    args << "--enable-jack" if build.with? 'jackosx'

    GitVersionWriter.new(@downloader).write if build.head?

    system "./configure", *args
    system "make install"

    if build.with? 'dist-bundle'
      system "make osxbundle"
      prefix.install "mpv.app"
    end

    if build.with? 'bundle'
      system "make osxbundle-skip-deps"
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
