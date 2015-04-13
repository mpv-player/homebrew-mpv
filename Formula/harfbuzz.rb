class Harfbuzz < Formula
  homepage "http://www.freedesktop.org/wiki/Software/HarfBuzz"
  url "http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.40.tar.bz2"
  sha256 "1771d53583be6d91ca961854b2a24fb239ef0545eed221ae3349abae0ab8321f"

  depends_on "pkg-config" => :build
  depends_on "freetype"

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    system "./configure", *args
    system "make", "install"
  end
end

