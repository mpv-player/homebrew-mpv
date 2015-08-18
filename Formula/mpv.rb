require 'formula'

class Mpv < Formula
  url 'https://github.com/mpv-player/mpv/archive/v0.9.2.tar.gz'
  sha256 'c0148f55dbd17705f49bb496d0ce374419de62e1b17195d91409d7727cbd4751'
  head 'https://github.com/mpv-player/mpv.git',
    :branch => ENV['MPV_BRANCH'] || "master"
  homepage 'https://github.com/mpv-player/mpv'

  depends_on 'pkg-config' => :build
  depends_on :python

  option 'with-official-libass', 'Use official version of libass'
  option 'with-libmpv',          'Build shared library.'
  option 'without-optimization', 'Disable compiler optimization.'
  option 'without-bundle',       'Disable compilation of a Mac OS X Application bundle.'
  option 'without-zsh-comp',     'Install without zsh completion'

  if build.with? 'official-libass'
    depends_on 'libass' => 'with-harfbuzz'
  else
    depends_on 'mpv-player/mpv/libass-ct'
  end

  depends_on 'ffmpeg'

  depends_on 'mpg123'      => :recommended
  depends_on 'jpeg'        => :recommended

  depends_on 'libcaca'     => :optional
  depends_on 'libbs2b'     => :optional
  depends_on 'libdvdread'  => :optional
  depends_on 'libdvdnav'   => :optional
  depends_on 'little-cms2' => :recommended
  depends_on 'lua'         => :recommended
  depends_on 'youtube-dl'  => :recommended
  depends_on 'libbluray'   => :optional
  depends_on 'libaacs'     => :optional
  depends_on :x11          => :optional

  if build.with? 'official-libass'
    depends_on 'vapoursynth' => [:optional, 'with-official-libass']
  else
    depends_on 'vapoursynth' => :optional
  end

  depends_on 'python3' if build.with? 'vapoursynth'

  WAF_VERSION = "waf-1.8.12".freeze
  WAF_SHA256    = "01bf2beab2106d1558800c8709bc2c8e496d3da4a2ca343fe091f22fca60c98b".freeze

  resource 'waf' do
    url "https://waf.io/#{WAF_VERSION}"
    sha256 WAF_SHA256
  end

  resource 'docutils' do
    url 'https://pypi.python.org/packages/source/d/docutils/docutils-0.11.tar.gz'
    sha256 '9af4166adf364447289c5c697bb83c52f1d6f57e77849abcccd6a4a18a5e7ec9'
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
    args << "--enable-libmpv-shared" if build.with? "libmpv"
    args << "--disable-optimize" if build.without? "optimization" and build.head?
    args << "--enable-zsh-comp" if build.with? "zsh-comp"

    buildpath.install resource('waf').files(WAF_VERSION => "waf")
    system "python", "waf", "configure", *args
    system "python", "waf", "install"

    if build.with? 'bundle'
      ohai "creating a OS X Application bundle"
      system "python", "TOOLS/osxbundle.py", "build/mpv"
      prefix.install "build/mpv.app"
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
