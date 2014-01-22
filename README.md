homebrew-mpv
============

A centralized repository for [mpv](https://github.com/mpv-player/mpv) related brews.

Requirements
------------

Docutils is required to install mpv.

    [sudo] easy_install pip
    pip install docutils

To have complete features, the development version of FFmpeg is **recommended**.

    brew install --devel ffmpeg

Usage
-----

    brew tap mpv-player/mpv
    brew install --HEAD mpv-player/mpv/libass-ct
    brew install mpv

The build is by default very minimal, but many dependencies can be added.
To get all the available build options:

    brew info mpv

To update the tapped formulae from this repository use:

    brew update

Available formulas
------------------

 *  mpv: builds mpv stable releases or git HEAD
 *  libass-ct: builds libass with experimental CoreText support
