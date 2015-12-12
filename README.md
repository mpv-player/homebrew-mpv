homebrew-mpv
============

A centralized repository for [mpv](https://github.com/mpv-player/mpv) related brews.

Usage
-----

    brew tap mpv-player/mpv
    brew install mpv

The build is by default very minimal, but many dependencies can be added.
To get all the available build options:

    brew info mpv

To update the tapped formulae from this repository use:

    brew update

**NOTE**: Compilation on OS X 10.7 is currently broken. 10.8 and later should
be fine.

Available formulas
------------------

 *  mpv: mpv stable releases or git HEAD
 *  vapoursynth: vapoursynth with python3 support
 *  mvtools: mvtools vapoursynth filter
