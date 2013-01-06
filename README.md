homebrew-mpv
============

A centralized repository for `mpv` related brews.

Usage
-----

 *  make sure you have Homebrew 0.9
 *  `brew tap mpv-player/mpv`

To install with FFmpeg (default):
 *  `brew install --HEAD mpv`

If you want to use libav instead of FFmpeg (which is default):
 *  `brew install --HEAD mpv-player/mpv/libav`: since brew will error out on
    mpv's installation because libav is a head only formula. Just install it
    manually.
 *  `brew install --HEAD mpv --with-libav`

To update the tapped formulae from this repository use `brew update`.

Available formulas
------------------

 *  libav: builds libav HEAD
 *  mpv: builds mpv HEAD
