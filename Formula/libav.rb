require 'formula'

class Libav < Formula
  head 'git://git.libav.org/libav.git', :using => :git
  homepage 'http://www.libav.org/'
  url 'http://libav.org/releases/libav-9.8.tar.gz'
  sha1 '45e612028f4ebe6ed8b24434e78d54e7c1145fd3'

  depends_on 'pkg-config' => :build
  depends_on 'yasm' => :build

  option "without-x264", "Disable H.264 encoder"
  option "without-lame", "Disable MP3 encoder"
  option "without-xvid", "Disable Xvid MPEG-4 video encoder"

  option "with-rtmpdump", "Enable RTMP protocol"
  option "with-libvo-aacenc", "Enable VisualOn AAC encoder"
  option "with-libass", "Enable ASS/SSA subtitle format"
  option "with-openjpeg", 'Enable JPEG 2000 image format'
  option 'with-openssl', 'Enable SSL support'
  option 'with-schroedinger', 'Enable Dirac video format'
  option 'with-ffplay', 'Enable FFplay media player'
  option 'with-tools', 'Enable additional FFmpeg tools'
  option 'with-fdk-aac', 'Enable the Fraunhofer FDK AAC library'

  depends_on 'x264' => :recommended
  depends_on 'faac' => :recommended
  depends_on 'lame' => :recommended
  depends_on 'xvid' => :recommended

  depends_on :freetype => :optional
  depends_on 'theora' => :optional
  depends_on 'libvorbis' => :optional
  depends_on 'libvpx' => :optional
  depends_on 'rtmpdump' => :optional
  depends_on 'opencore-amr' => :optional
  depends_on 'libvo-aacenc' => :optional
  depends_on 'libass' => :optional
  depends_on 'openjpeg' => :optional
  depends_on 'sdl' if build.include? 'with-ffplay'
  depends_on 'speex' => :optional
  depends_on 'schroedinger' => :optional
  depends_on 'fdk-aac' => :optional
  depends_on 'opus' => :optional
  depends_on 'frei0r' => :optional
  depends_on 'libcaca' => :optional

  conflicts_with 'ffmpeg',
    :because => 'libav and ffmpeg install the same libraries'

  def install
    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}",
            "--disable-debug",
            "--enable-shared",
            "--enable-gpl",
            "--enable-version3",
            "--enable-nonfree",
            "--host-cflags=#{ENV.cflags}",
            "--host-ldflags=#{ENV.ldflags}",
            # uses sem_timedwait which is not available on OSX
            "--disable-indev=jack"]

    args << "--enable-libx264" if build.with? 'x264'
    args << "--enable-libfaac" if build.with? 'faac'
    args << "--enable-libmp3lame" if build.with? 'lame'
    args << "--enable-libxvid" if build.with? 'xvid'

    args << "--enable-libfreetype" if build.with? 'freetype'
    args << "--enable-libtheora" if build.with? 'theora'
    args << "--enable-libvorbis" if build.with? 'libvorbis'
    args << "--enable-libvpx" if build.with? 'libvpx'
    args << "--enable-librtmp" if build.with? 'rtmpdump'
    args << "--enable-libopencore-amrnb" << "--enable-libopencore-amrwb" if build.with? 'opencore-amr'
    args << "--enable-libvo-aacenc" if build.with? 'libvo-aacenc'
    args << "--enable-libass" if build.with? 'libass'
    args << "--enable-ffplay" if build.include? 'with-ffplay'
    args << "--enable-libspeex" if build.with? 'speex'
    args << '--enable-libschroedinger' if build.with? 'schroedinger'
    args << "--enable-libfdk-aac" if build.with? 'fdk-aac'
    args << "--enable-openssl" if build.with? 'openssl'
    args << "--enable-libopus" if build.with? 'opus'
    args << "--enable-frei0r" if build.with? 'frei0r'
    args << "--enable-libcaca" if build.with? 'libcaca'

    if build.with? 'openjpeg'
      args << '--enable-libopenjpeg'
      args << '--extra-cflags=' + %x[pkg-config --cflags libopenjpeg].chomp
    end

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
