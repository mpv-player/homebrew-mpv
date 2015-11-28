require "formula"

class F3kdb < Formula
  homepage "https://github.com/SAPikachu/flash3kyuu_deband"
  head     "https://github.com/SAPikachu/flash3kyuu_deband.git"

  needs :cxx11
  depends_on 'pkg-config' => :build
  depends_on :python3

  def install
    system "python3", "waf", "configure", "--prefix=#{prefix}"
    system "python3", "waf", "install"
  end
end

