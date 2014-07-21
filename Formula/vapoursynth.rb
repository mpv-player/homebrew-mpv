require "formula"

class Vapoursynth < Formula
  homepage "http://www.vapoursynth.com"
  head "https://github.com/vapoursynth/vapoursynth.git"

  needs :cxx11

  depends_on 'pkg-config' => :build
  depends_on 'yasm'       => :build
  depends_on 'sphinx'     => :build
  depends_on :python3

  depends_on 'ffmpeg'
  depends_on 'libass-ct'

  depends_on 'tesseract'  => :optional

  WAF_VERSION = "waf-1.7.15".freeze

  resource 'waf' do
    url "https://waf.googlecode.com/files/#{WAF_VERSION}"
    sha1 'c5c2ed76b72a81ee0154265cbb55d6c7cdce434f'
  end


  def install
    buildpath.install resource('waf').files(WAF_VERSION => "waf")
    args = [ "--prefix=#{prefix}" ]

    system "python3", "waf", "configure", *args
    system "python3", "waf", "build"

    system "pip3", "install", "Cython"
    system "python3", "setup.py", "build"

    system "python3", "waf", "install"
    system "python3", "setup.py", "install"
  end
end
