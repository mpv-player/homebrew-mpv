require 'formula'

def avplay?
  ARGV.include? '--with-avplay'
end

class Libav <Formula
  head 'git://git.libav.org/libav.git', :using => :git,
    :ref => '4f935a7b89e44fc0fd05c340c17bddcb6a407cb'
  homepage 'http://www.libav.org/'

  depends_on :x11
  depends_on 'pkg-config' => :build
  depends_on 'yasm' => :build

  depends_on 'x264' => :optional
  depends_on 'faac' => :optional
  depends_on 'lame' => :optional
  depends_on 'rtmpdump' => :optional
  depends_on 'libvorbis' => :optional
  depends_on 'libogg' => :optional
  depends_on 'libvpx' => :optional
  depends_on 'xvid' => :optional
  depends_on 'opencore-amr' => :optional
  depends_on 'libass' => :optional

  conflicts_with 'ffmpeg',
    :because => 'libav and ffmpeg install the same libraries'

  def options
    [
      ["--with-avplay", "Build avplay."]
    ]
  end

  depends_on 'sdl' if avplay?

  def install
    ENV.x11
    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}",
            "--disable-debug",
            "--enable-shared",
            "--enable-gpl",
            "--enable-version3",
            "--enable-nonfree",
            "--enable-libfreetype"]

    args << "--enable-libx264"
    args << "--enable-libfaac" if Formula.factory('faac').installed?
    args << "--enable-libmp3lame" if Formula.factory('lame').installed?
    args << "--enable-librtmp" if Formula.factory('rtmpdump').installed?
    args << "--enable-libvorbis" if Formula.factory('libvorbis').installed?
    args << "--enable-libvpx" if Formula.factory('libvpx').installed?
    args << "--enable-libxvid" if Formula.factory('xvid').installed?
    args << "--disable-avplay" unless avplay?

    # For 32-bit compilation under gcc 4.2, see:
    # http://trac.macports.org/ticket/20938#comment:22
    if MacOS.leopard? or Hardware.is_32_bit?
      ENV.append_to_cflags "-mdynamic-no-pic"
    end

    system "./configure", *args

    if MacOS.prefer_64_bit?
      inreplace 'config.mak' do |s|
        shflags = s.get_make_var 'SHFLAGS'
        if shflags.gsub!(' -Wl,-read_only_relocs,suppress', '')
          s.change_make_var! 'SHFLAGS', shflags
        end
      end
    end

    system "make install"
  end
end
