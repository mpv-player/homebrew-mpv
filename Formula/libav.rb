require 'formula'

def avplay?
  build.include? 'with-avplay'
end

def freetype?
  build.include? 'with-freetype'
end

class Libav < Formula
  head 'git://git.libav.org/libav.git', :using => :git
  homepage 'http://www.libav.org/'
  url 'http://libav.org/releases/libav-9.8.tar.gz'
  sha1 '45e612028f4ebe6ed8b24434e78d54e7c1145fd3'

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

  option 'with-avplay', 'Build avplay'
  option 'with-freetype', 'Enable FreeType'

  depends_on :freetype if freetype?
  depends_on 'sdl' if avplay?

  def install
    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}",
            "--disable-debug",
            "--enable-shared",
            "--enable-gpl",
            "--enable-version3",
            "--enable-nonfree",
            # uses sem_timedwait which is not available on OSX
            "--disable-indev=jack"]

    args << "--enable-libfreetype" if freetype?
    args << "--enable-libx264" if Formula.factory('x264').installed?
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
