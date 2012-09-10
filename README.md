homebrew-mplayer2
=================

A centralized repository for mplayer2 related brews.

Usage
-----

 *  make sure you have Homebrew 0.9
 *  `brew tap pigoz/mplayer2`

To install with FFmpeg (default):
 *  `brew install --HEAD pigoz/mplayer2/mplayer2`

If you want to use libav instead of FFmpeg:
 *  `brew install --HEAD pigoz/mplayer2/libav`: since brew will error out on
    mplayer2's installation because libav is a head only formula. Just
    install it manually.
 *  `brew install --HEAD pigoz/mplayer2/mplayer2 --with-libav`

To update the tapped formulae from this repository use `brew update`.

Why is FFmpeg default?
----------------------

mplayer2 is currently not compatible with audio using planar sample formats
which libav uses: this results in broken ALAC support. FFmpeg also has a Video
Decode Acceleration (VDA) decoder that mplayer2 can use for accelerating h264
decoding.

Available formulas
------------------

 *  libav: official libav HEAD
 *  mplayer2: official mplayer2 HEAD
