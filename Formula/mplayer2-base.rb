module Mplayer2Base
  def self.included(base)
    base.class_eval do
      homepage 'http://mplayer2.org'

      depends_on 'pkg-config' => :build
      depends_on 'libbs2b' => :build
      depends_on 'libass' => :build
      depends_on 'homebrew/dupes/freetype' => :build
      depends_on 'fontconfig' => :build
      depends_on 'pigoz/mplayer2/libav' => :build
      depends_on 'python3' => :build
    end
  end

  def install
    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}",
            "--enable-macosx-bundle",
            "--enable-macosx-finder",
            "--enable-apple-remote"]

    generate_version
    system "./configure", *args
    system "make install"

    mv bin + 'mplayer', bin + binary_name
  end

  private
  def generate_version
    ohai "Generating VERSION from the Homebrew's git cache"
    File.open('VERSION', 'w') {|f| f.write(git_revision) }
  end

  def git_revision
    `cd #{git_cache} && git describe --match "v[0-9]*" --always`.strip
  end

  def git_cache
    @downloader.cached_location
  end
end
