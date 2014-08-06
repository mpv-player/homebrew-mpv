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
  url 'https://github.com/mpv-player/mpv/archive/v0.4.2.tar.gz'
  sha1 'b379e3b1a30fc646845ffb545bff16b8e9fcef54'
  head 'https://github.com/mpv-player/mpv.git',
    :branch => ENV['MPV_BRANCH'] || "master"
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'pkg-config' => :build
  depends_on :python

  option 'with-official-libass', 'Use official version of libass (instead of experimental CoreText based branch)'
  option 'with-libav',           'Build against libav instead of ffmpeg.'
  option 'with-libmpv',          'Build shared library.'
  option 'without-optimization', 'Disable compiler optimization.'
  option 'without-bundle',       'Disable compilation of a Mac OS X Application bundle.'
  option 'with-jackosx',         'Build with jackosx support.'
  option 'without-zsh-comp',     'Install without zsh completion'

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
  depends_on 'vapoursynth' => :optional

  depends_on 'python3' if build.with? 'vapoursynth'
  depends_on JackOSX.new if build.with? 'jackosx'

  WAF_VERSION = "waf-1.7.16".freeze

  resource 'waf' do
    url "http://ftp.waf.io/pub/release/#{WAF_VERSION}"
    sha1 'cc67c92066dc5b92a4942f9c1c25f8fea6be58b5'
  end

  resource 'docutils' do
    url 'https://pypi.python.org/packages/source/d/docutils/docutils-0.11.tar.gz'
    sha1 '3894ebcbcbf8aa54ce7c3d2c8f05460544912d67'
  end

  def caveats
    bundle_caveats if build.with? 'bundle'
  end

  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec/'lib/python2.7/site-packages'
    ENV.prepend_create_path 'PATH', libexec/'bin'
    ENV.append 'LC_ALL', 'en_US.UTF-8'
    resource('docutils').stage { system "python", "setup.py", "install", "--prefix=#{libexec}" }
    bin.env_script_all_files(libexec/'bin', :PYTHONPATH => ENV['PYTHONPATH'])

    if build.with? 'vapoursynth'
      pyver = Language::Python.major_minor_version Formula['python3'].bin/'python3'
      ENV.append_path 'PKG_CONFIG_PATH', Formula['python3'].frameworks/'Python.framework/Versions'/pyver/'lib/pkgconfig'
    end

    args = [ "--prefix=#{prefix}" ]
    args << "--enable-jack" if build.with? 'jackosx'
    args << "--enable-libmpv-shared" << "--disable-client-api-examples" if build.with? "libmpv"
    args << "--disable-optimize" if build.without? "optimization" and build.head?
    args << "--enable-zsh-comp" if build.with? "zsh-comp"

    # For running version.sh correctly
    buildpath.install_symlink cached_download/".git" if build.head?
    buildpath.install resource('waf').files(WAF_VERSION => "waf")
    system "python", "waf", "configure", *args
    system "python", "waf", "install"

    if build.with? 'bundle'
      ohai "creating a OS X Application bundle"
      system "python", "TOOLS/osxbundle.py", "build/mpv"
      prefix.install "build/mpv.app"
    end

    # install zsh completion
    if build.with? "zsh-comp"
      zsh_completion.install share/'zsh/vendor-completions/_mpv'
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
