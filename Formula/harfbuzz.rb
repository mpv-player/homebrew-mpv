class Harfbuzz < Formula
  homepage "http://www.freedesktop.org/wiki/Software/HarfBuzz"
  url "http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.38.tar.bz2"
  sha256 "6736f383b4edfcaaeb6f3292302ca382d617d8c79948bb2dd2e8f86cdccfd514"

  depends_on "pkg-config" => :build
  depends_on "freetype"

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]
    system "./configure", *args
    system "make", "install"
  end
end

