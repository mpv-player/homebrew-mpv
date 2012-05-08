require 'formula'

def avplay?
  ARGV.include? '--with-avplay'
end

class Libav <Formula
  head 'git://git.libav.org/libav.git', :using => :git
  homepage 'http://www.libav.org/'

  depends_on 'pkg-config' => :build
  depends_on 'yasm' => :build

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
