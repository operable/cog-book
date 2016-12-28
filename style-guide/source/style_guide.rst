The Cog Book Author Style Guide
===============================

This document is meant as both description and example to encourage
standard practices amongst Cog Book contributors. It will include
preferred or recommended approaches for selecting among AsciiDoc
formatting options, organizing information flow, and presenting code and
other examples. It also contains the complete list of approved jokes,
witticisms, and wry remarks acceptable for adding levity to The Cog
Book.

    **Note**

    The information in this file is intended as recommendations or
    defaults. These are the general rules, but if you have a specific
    reason to use a different approach, you are welcome to do so.

Resources
---------

`The Asciidoctor User
Manual <http://asciidoctor.org/docs/user-manual/>`__

Section Headers
---------------

Syntax
~~~~~~

Use ``=`` for all header designations. AsciiDoc permits multiple
options, including ``#`` but for consistency we’d like to stick to the
default.

Application
~~~~~~~~~~~

**Level 0: Chapter Groups.**

``= Level 0 - Chapter Group``

This header groups chapters into a theme. Define these groups in the
cog\_book.adoc file to organize similar sets of separate chapters.

**Level 1: Chapters.**

``== Level 1 - Chapter Title``

Level 1 Section Headers introduce chapters devoted to a single subject.
Each chapter gets its own separate adoc file and subfolder in the src
folder.

The Level 1 Chapters are attached the book with the ``include`` command
in the main ``cog_book.adoc`` file. Through this combination of Level 1
and the Level 0 titles, the ``cog_book.adoc`` file provides a sense of
the structure of the document without overloading details. That
structure only displays to other Cog Book contributors but it enables
them to see and easily manage content flow at the top level of
organization.

**Level 2: Sections.**

``=== Level 2 - Sections``

Level 2 Sections separate individual topics within a Chapter. These are
the lowest level of detail in the Cog Book Table of Contents and the
basic element of engagement for Cog Book readers. In most instances,
Level 2 is also the first place to start filling in the text of the
work. With the exception of some introductory paragraphs or a Chapter
opening, Level 2 is where the work gets done.

**Level 3: Sub-sections and below.**

``==== Level 3 - Sub-sections``

Level 3 sub-sections can help break up the Level 2 Sections into
discrete pieces. They are likely to describe an individual action within
a larger series or describe an alternate option.

**Level 4: Super-secret sub-basement.**

``===== Level 4 - Super-secret sub-basement``

Yeah, don’t do this. If you find yourself diving this deep into the
headers, you might want to reconsider your organization. A section
upstream trying to contain too much should be promoted, split up, or
removed entirely.

Displaying code
---------------

AsciiDoc can display formatted code using Source Blocks. Each block
identifies the code represented within it.

Standard Source block structure
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use appropriate code designations (yaml, bash, sh, shell…) and which to
use when multiple are appropriate Title conventions

.. raw:: html

   <div class="informalexample">

::

    .This is a title 
    [source, bash] 
    ----
    This is where the code goes.
    If you use the correct source designator, this text will be formatted relative to that code style.
    ----

-  Use short descriptive titles

-  Use the appropriate source language. See below for suggested
   defaults.

**This is a title.**

.. code:: bash

    This is where the code goes.
    If you use the correct source designator, this text will be formatted relative to that code style.

.. raw:: html

   </div>

**Command Line interface.**

Use ``bash`` for command line interface examples unless you have a
specific reason to use another option.

**Configuration files.**

Most configuration files should be sourced in ``YAML``.

**Specific language examples.**

Use the specific language. Anything else would be silly. Seriously.

Admonition blocks
-----------------

Application
~~~~~~~~~~~

AsciiDoc has five levels of admonition blocks: \* NOTE \* TIP \*
IMPORTANT \* CAUTION \* WARNING

    **Note**

    Use NOTE blocks for simple examples, asides, or references to
    related sections. Note blocks are asides, however, not the main
    point. They’re extras; the fries, not the burger.

    **Tip**

    Use TIP blocks to recommend best practices or suggest an approach
    that can highlight Cog’s potential in a way the reader might not
    have considered.

    **Important**

    Use IMPORTANT blocks for critical information the reader will need
    to know to successfully use Cog. This is a place to emphasize and
    repeat fundamentals.

    **Caution**

    Use CAUTION blocks to point out complicated aspects of the topic at
    hand or describe common mistakes.

    **Warning**

    Use WARNING blocks to alert the reader to the potential for critical
    failures or significant setbacks.

Syntax
~~~~~~

**Simple NOTE formatting.**

This

::

    .Clever title
    NOTE: Witty observation

produces this…

    **Note**

    Witty observation

Easy peasy.

**Complex NOTE formatting.**

If you want to put bullet lists, tables, or multiple paragraphs inside a
NOTE, you’ll need to treat it like a block.

You need this:

::

    [NOTE] 
    .More complex, this note is 
    ==== 
    * Bullet points
    * and other complex things...

    ...like a whole new paragraph.
    ====

-  Define the kind of block you’re using.

-  This time the title comes second.

-  Define the limits of the block with ``====``

To get this:

    **Note**

    -  Bullet points

    -  and other complex things…

    …like a whole new paragraph.

    **Warning**

        **Tip**

        Don’t do this. What is wrong with you?

Images
------
