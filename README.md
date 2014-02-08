homebrew-mpv
============

A centralized repository for [mpv](https://github.com/mpv-player/mpv) related brews.

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

homebrew-cask
=============

If you use [homebrew-cask](https://github.com/phinze/homebrew-cask) and want to get [Releases](https://github.com/mpv-player/mpv/releases):

    brew tap phinze/cask
    brew install brew-cask
    brew cask install mpv
