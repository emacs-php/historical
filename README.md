# About #

This mode is derived from the [original php-mode for
emacs](http://php-mode.sourceforge.net/). Several other people on
github have forks with various enhancements to the original. I am
building on these, and adding improvements of my own in order to fix
various bugs, as well as bring the mode up to date with new versions
of PHP.

# Installation #

To install, you can clone this repo into a directory of your choice (I
use ~/.emacs.d/php-mode).

Then add something like this to your .emacs configuration:

(add-to-list 'load-path (expand-file-name "~/.emacs.d/php-mode"))
(require 'php-mode)

And you're off to the races!

# Bugs & Improvements #

You can report any problems that you find on github's integrated issue
tracker. If you've added some improvements and you want them included
upstream don't hesitate to send me a patch or, even better, a GitHub
pull request.
