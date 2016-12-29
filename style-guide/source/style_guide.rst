The Cog Book Author Style Guide
===============================

This document is meant as both description and example to encourage
standard practices amongst Cog Book contributors. It will include
preferred or recommended approaches for selecting among reStructuredText
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

`Quick reStructuredText <http://docutils.sourceforge.net/docs/user/rst/quickref.html>`__

Section Headers
---------------

Syntax
~~~~~~

Use the header underline characters in the following order ``= - ~ ^``.  Sphinx and reStructuredText can handle a wide variety but for consistency we'd like the same characters to always represent the same organization level.

Application
~~~~~~~~~~~

**Level 1: Chapter Groups.**

::

  Chapter Group
  =============

This header groups chapters into a theme. Define these groups in the
index.rst file to organize similar sets of separate chapters.

.. RS NOTE: This level is a holdover from the cog_book.io and the AsciiDoc include formatting.  Do we still want to use these groups?  They're not currently in place in the new Sphinx version as of this writing.  It may not be relevant if we move towards the separate Admin/User/Dev Guide structures (this Chapter Group would basically be the "Guide" level)

**Level 2: Chapters.**

::

  Chapter
  -------

The second level headers introduce chapters devoted to a single subject.
Each chapter gets its own separate .rst file and included in the book as a listing in the main ``index.rst`` file.

**Level 3: Sections.**

::

  Section
  ~~~~~~~

Sections separate individual topics within a Chapter. These are
the basic element of engagement for Cog Book readers. In most instances,
the Section is also the first place to start filling in the text of the
work. With the exception of some introductory paragraphs or a Chapter
opening, Sections are where the work gets done.

**Level 4: Sub-sections and below.**

::

  Sub-sections
  ^^^^^^^^^^^^

Sub-sections can help break the Sections into discrete pieces. They are likely to describe an individual action within
a larger series or describe an alternate option.

**Level 5: Super-secret sub-basement.**

::

  Super-secret sub-basement
  *************************

Yeah, don’t do this. If you find yourself diving this deep into the
headers, you might want to reconsider your organization. A section
upstream is likely trying to contain too much and should be promoted, split up, or
removed entirely.

Displaying code
---------------

.. STILL DESCRIBES THE ASCIIDOC APPROACH, TO BE CONVERTED TO SPHINX/reStructuredText.

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
