# About #

This mode is derived from the [original php-mode for
emacs](http://php-mode.sourceforge.net/). Several other people on
github have forks with various enhancements to the original. I am
building on these, and adding improvements of my own in order to fix
various bugs, as well as bring the mode up to date with new versions
of PHP.

Recent improvements include:

* support for traits (PHP 5.4+)
* support for namespaces (PHP 5.3+)
* support for namespace aliases (PHP 5.3+)
* support for anonymous functions (PHP 5.3+)

# Installation #

To install, you can clone this repo into a directory of your choice (I
use ~/.emacs.d/php-mode).

Then add something like this to your .emacs configuration:

    (add-to-list 'load-path (expand-file-name "~/.emacs.d/php-mode"))
    (require 'php-mode)

And you're off to the races!

# Bug Fixes & Other Improvements #

You can report any problems that you find on github's integrated issue
tracker. If you've added some improvements and you want them included
upstream don't hesitate to send me a patch or, even better, a GitHub
pull request.

# Contributors #

This is a list of people who have contributed to the mode, in
chronological order from oldest to newest:

Turadg Aleahmad (original author), Aaron S. Hawley, Juanjo, Torsten
Martinsen, Vinai Kopp, Sean Champ, Doug Marcey, Kevin Blake, Rex
McMaster, Mathias Meyer, Boris Folgmann, Roland Rosenfeld, Fred
Yankowski, Craig Andrews, John Keller, Ryan Sammartino, ppercot,
Valentin Funk, Stig Bakken, Gregory Stark, Chris Morris, Nils
Rennebarth, Gerrit Riessen, Eric Mc Sween, Ville Skytta, Giacomo
Tesio, Lennart Borgman, Stefan Monnier, Aaron S. Hawley, Ian Eure,
Bill Lovett, Dias Badekas, David House, Luka Novsak, Ranko Radonic,
Grzegorz Rożniecki, Yusuke Segawa
