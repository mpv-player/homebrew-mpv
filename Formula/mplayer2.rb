require 'formula'

class Mplayer2 <Formula
  head 'git://git.mplayer2.org/mplayer2.git', :using => :git
  homepage 'http://mplayer2.org'

  depends_on 'pkg-config' => :build
  depends_on 'libbs2b' => :build
  depends_on 'libass' => :build
  depends_on 'homebrew/dupes/freetype' => :build
  depends_on 'pigoz/mplayer2/libav' => :build

  def install
    args = ["--prefix=#{prefix}",
            "--cc=#{ENV.cc}",
            "--enable-macosx-bundle",
            "--enable-macosx-finder",
            "--enable-apple-remote"]

    gen_version_h
    system "./configure", *args
    system "make install"

    # change the binary name to mplayer2
    FileUtils.mv(bin + 'mplayer', bin + 'mplayer2')
  end

  def patches
    # prevents make install from generating a wrong version.h since we don't
    # have the .git directory in the building stage.
    DATA
  end

  private
  def gen_version_h
    ohai "Generating version.h from the Homebrew's git cache"
    system "cd #{git_cache} && ./version.sh"
    system "cp #{git_cache}/version.h version.h"
  end

  def git_cache
    @downloader.cached_location
  end
end

__END__
From fc0a5ab6982c9c57aaa369a201ec8837ef7f20b0 Mon Sep 17 00:00:00 2001
From: Stefano Pigozzi <stefano.pigozzi@gmail.com>
Date: Wed, 9 May 2012 11:40:56 +0200
Subject: [PATCH] make the Makefile version.h target into a no-op

---
 Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index 5877335..e6f02f5 100644
--- a/Makefile
+++ b/Makefile
@@ -607,7 +607,7 @@ config.mak: configure
 	@echo "############################################################"
 
 version.h .version: version.sh
-	./$<
+	@echo "skip version.h generation"
 
 # Force version.sh to run to potentially regenerate version.h
 -include .version
-- 
1.7.7.5 (Apple Git-26)
