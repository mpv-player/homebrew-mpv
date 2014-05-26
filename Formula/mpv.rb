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

class Mpv < Formula
  url 'https://github.com/mpv-player/mpv/archive/v0.3.10.tar.gz'
  sha1 '86880f992a4418cfa8ce0b80b5305572a6105bfa'
  head 'https://github.com/mpv-player/mpv.git',
    :branch => ENV['MPV_BRANCH'] || "master"
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'pkg-config' => :build
  depends_on :python

  option 'with-official-libass', 'Use official version of libass (instead of experimental CoreText based branch)'
  option 'with-libav',           'Build against libav instead of ffmpeg.'
  option 'with-libmpv',          'Build shared library.'
  option 'without-bundle',       'Disable compilation of a Mac OS X Application bundle.'
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
  depends_on 'little-cms2' => :recommended
  depends_on 'lua'         => :recommended
  depends_on 'libbluray'   => :optional
  depends_on 'libaacs'     => :optional
  depends_on :x11          => :optional

  depends_on JackOSX.new if build.with? 'jackosx'

  WAF_VERSION = "waf-1.7.15".freeze

  resource 'waf' do
    url "https://waf.googlecode.com/files/#{WAF_VERSION}"
    sha1 'c5c2ed76b72a81ee0154265cbb55d6c7cdce434f'
  end

  resource 'docutils' do
    url 'https://pypi.python.org/packages/source/d/docutils/docutils-0.11.tar.gz'
    sha1 '3894ebcbcbf8aa54ce7c3d2c8f05460544912d67'
  end

  def caveats
    bundle_caveats unless build.without? 'bundle'
  end

  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'
    ENV.prepend_create_path 'PATH', libexec+'bin'
    resource('docutils').stage { system "python", "setup.py", "install", "--prefix=#{libexec}" }
    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])

    args = [ "--prefix=#{prefix}" ]
    args << "--enable-jack" if build.with? 'jackosx'
    args << "--enable-libmpv-shared" << "--disable-client-api-examples" if build.with? "libmpv"

    # For running version.sh correctly
    buildpath.install_symlink cached_download/".git" if build.head?
    buildpath.install resource('waf').files(WAF_VERSION => "waf")
    system "python", "waf", "configure", *args
    system "python", "waf", "install"

    unless build.without? 'bundle'
      ohai "creating a OS X Application bundle"
      system "python", "TOOLS/osxbundle.py", "build/mpv"
      bin.install "build/mpv.app"
    end
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
