[![Build Status](https://travis-ci.org/operable/cog-book.svg?branch=master)](https://travis-ci.org/operable/cog-book)

[The Cog Book](https://operable.github.io/cog-book/)
============

This is the home of The Cog Book, the definitive reference for the [Cog](https://github.com/operable/cog) chat platform, by [Operable](https://operable.io).

The book is written in [reStructuredText](https://en.wikipedia.org/wiki/ReStructuredText) and built using [Sphinx](http://sphinx-doc.org).

The build toolchain is contained in the [operable/cog-book-toolchain:sphinx](https://hub.docker.com/r/operable/cog-book-toolchain/) Docker image. If you have [Docker](https://docker.com) installed, you can build the book by running `make cog-book`. You can browse the newly built docs by opening `build/cog-book/html/index.html` in a browser.

