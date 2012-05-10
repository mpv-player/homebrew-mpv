homebrew-mplayer2
=================

A centralized repository for mplayer2 related brews.

Usage
-----

 *  make sure you have Homebrew 0.9
 *  `brew tap pigoz/mplayer2`
 *  `brew install --HEAD pigoz/mplayer2/libav`: since brew will error out on
    mplayer2's installation because libav is a head only formula. Just
    install it manually.
 *  `brew install --HEAD pigoz/mplayer2/mplayer2` or `brew install
    --HEAD pigoz/mplayer2/mplayer2-wm4`

To update the tapped formulae from this repository use `brew update pigoz/mplayer2`.

Available formulas
------------------

 *  libav: official libav HEAD
 *  mplayer2: official mplayer2 HEAD
 *  mplayer2-wm4: wm4's mplayer2 HEAD, this version includes a lot of additional
    functionality, such as `-vo gl3`.
