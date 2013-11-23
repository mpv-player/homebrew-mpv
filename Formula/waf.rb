require 'formula'

class Waf < Formula
  url 'https://waf.googlecode.com/files/waf-1.7.13'
  sha1 'f97a8675aa0f6ddf2f8a05d45d44881d2d1a3c8e'
  homepage 'https://code.google.com/p/waf'

  depends_on :python

  # keg_only <<-TEXT.undent
  #   This is only needed for mpv. No need to expose it outside the Cellar.
  # TEXT

  def install
    bin.install 'waf-1.7.13' => 'waf'
  end
end
