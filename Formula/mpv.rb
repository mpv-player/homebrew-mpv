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
  url 'https://github.com/mpv-player/mpv/archive/v0.3.6.tar.gz'
  sha1 'a60a49796f4181cb97f4469d2ca25b1b00db2f1d'
  head 'https://github.com/mpv-player/mpv.git'
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'mpv-player/mpv/waf' => :build
  depends_on 'pkg-config' => :build
  depends_on :python

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

  resource 'docutils' do
    url 'https://pypi.python.org/packages/source/d/docutils/docutils-0.11.tar.gz'
    sha1 '3894ebcbcbf8aa54ce7c3d2c8f05460544912d67'
  end

  def caveats
    bundle_caveats if build.with? 'bundle'
  end

  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'
    ENV.prepend_create_path 'PATH', libexec+'bin'
    resource('docutils').stage { system "python", "setup.py", "install", "--prefix=#{libexec}" }
    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])

    args = [ "--prefix=#{prefix}" ]
    args << "--enable-jack" if build.with? 'jackosx'
    args << "--enable-macosx-bundle" if build.with? 'bundle'

    GitVersionWriter.new(@active_spec.downloader).write if build.head?

    system "waf", "configure", *args
    system "waf", "install"
  end

  private
  def bundle_caveats; <<-EOS.undent
    mpv.app installed to:
      #{prefix}

    To link the application to a normal Mac OS X location:
        brew linkapps
    or:
        ln -s #{bin}/mpv.app /Applications
    EOS
  end
end
