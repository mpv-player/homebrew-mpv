require 'formula'
require File.join(File.dirname(__FILE__), 'mixins', 'mplayer2-base.rb')

class Mplayer2Wm4 < Formula
  include Mplayer2Base
  head 'git://git.mplayer2.org/wm4/mplayer2.git', :using => :git

  depends_on 'lcms2' => :build

  private
  def binary_name
    'mplayer2-wm4'
  end
end
