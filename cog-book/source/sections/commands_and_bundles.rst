Commands and Bundles
====================

As a chatops bot, commands are central to Cog. After all, without
commands, Cog wouldn’t actually do anything! Let’s take a look at
exactly what commands are, how they are organized, and how they are
managed.

**Current list Cog Bundles:** `Bundle
Warehouse <https://bundles.operable.io>`__

Let’s start with an example. If I type the following into Slack:

::

  !operable:help

I should receive a response that looks something like this:

::

  I know about these commands:

  *  date:date
  *  github:prs
  *  github:repo
  *  operable:bundle
  *  operable:echo
  *  operable:filter
  *  operable:greet
  *  operable:group
  *  operable:help
  *  operable:max
  *  operable:min
  *  operable:permissions
  *  operable:role
  *  operable:rules
  *  operable:sort
  *  operable:sum
  *  operable:table
  *  operable:thorn
  *  operable:unique
  *  operable:wc

  Try calling `operable:help COMMAND` to find out more.

I have just executed the ``help`` command from the ``operable`` command
bundle. From the response, I can see that the system currently has three
bundles installed (``date``, ``github``, and ``operable``), each of
which contains one or more commands. The ``date`` bundle contains a
single command (also named ``date``), the ``github`` bundle contains a
``prs`` and a ``repo`` command, and the ``operable`` bundle contains a
great deal of commands, one of which is the ``help`` command we just
invoked.

Commands
--------

If you view your chatbot as a kind of "shared command line", then
commands are like the executables in your terminal. In fact, you might
recognize several commands from the ``operable`` namespace above from
your everyday terminal usage: ``echo``, ``wc``, ``sort``, etc.

Command may need some additional information that would not be shared on
the "shared command line", but will have to be setup by an
administrator, such as an OAuth key. See the section on
:doc:`dynamic_command_configuration` for more information on how to
get this data for command execution.

Bundles
-------

Let’s say that you’ve written some new chat commands for Cog. You have
one command that spins up new machines in AWS and another that
terminates machines.

These commands are clearly related functionally; you probably won’t use
one without the other, after all. They also probably share a good bit of
library and / or dependency code. It would be nice to have a way to
package up these commands in a way that reflects this.

Enter **bundles**, the packaging unit for commands. Bundles contain all
the code for the commands within, including dependencies and library
code. They also carry metadata about the commands, including
documentation, details about the various options each command
recognizes, configuration that affects how the commands behave in
:doc:`execution pipelines <command_pipelines>`, and even formatting
templates, which allow the results of commands to be presented in the
best possible way for the chat system you use.

This sounds interesting, right? Come see how simple it is:
:doc:`writing_a_command_bundle`.

Bundle Permissions and Rules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bundles also contain an initial set of :doc:`permissions and authorization
rules <permissions_and_rules>` for their commands. When a bundle is
installed, these permissions and accompanying rules are automatically
created in the Cog system. These can be used as-is, or can be modified
by Cog operators in whatever way suits their organization best.

Since :doc:`permissions <permissions_and_rules>` are namespaced to the
bundle they originate from, installing a bundle’s permissions will never
conflict with any existing authorization system configurations you may
have made. No users are automatically assigned any of these permissions,
either.

Example: The ``operable`` Bundle
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``operable`` bundle is a unique bundle, in that it is effectively
built into the bot (in code, you will see it referred to as the
"embedded bundle"). All Cog instances will have this bundle installed
automatically, and this is how the core permissions and authorization
rules of the system come to be installed.

Invoking Commands
-----------------

To invoke a command, like ``operable:help``, you have a few options.

First, you can address the bot directly by name in a channel in which
the bot is listening. Here, my bot is named
`Marvin <https://en.wikipedia.org/wiki/Marvin_(character)>`__

::

  @marvin operable:help

Alternatively, you can configure the bot to use a "command prefix",
which defaults to ``!``.

::

  !operable:help

Finally, you can interact with the bot in 1-on-1 chat, in which case you
may simply type commands directly; everything you type to the bot is
considered a command.

::

  operable:help

Shortcuts
~~~~~~~~~

Fully qualifying all command names with their bundle can get tedious for
frequently-used commands, as well as for long pipeline sequences.
Fortunately, Cog uses a simple rule to alleviate much of this
frustration. If a command name *by itself* happens to be unique within a
Cog installation (that is, no other bundles have a command with the same
name), you may type the bare command. Thus our repeated invocations of
``operable:help`` could also have been written simply as ``help``, since
the ``operable`` bundle is the only bundle currently installed that has
a ``help`` command.

If on the other hand, your installation were to have two or more bundles
that had a ``help`` command, you would need to specify exactly which
``help`` command you wanted to invoke; ``operable:help``, ``foo:help``,
``bar:help``, etc. If there is any ambiguity about which command you are
trying to invoke, Cog will not execute *any* commands, and will instead
warn you.

Implementation Details
----------------------

Bundles may take one of two forms. The first, which we’ll call a
:ref:`standard <standard_bundle_target>` bundle is a docker image that contains
all of your commands. This is the form you’ll use if you have custom
code to implement your chat commands and wish to package that code and
distribute it in a bundle.

.. warning::
  Note that versions on Cog prior to version 0.4 used a different
  packaging system for standard bundles. These old bundles will not
  work for current versions of Cog.

The other form of bundle is a
:ref:`simple <simple_bundle_target>` bundle, which is
essentially just the ``config.yaml`` file from the "standard" bundle.
This form of bundle can be used to expose executables that are already
on the system path, which may be installed "out of band", using OS
packages, standard configuration management routes, etc.

It should be noted that "simple" bundles can still be configured to
accept arguments and options. The ``config.yaml`` file thus serves to
describe the command to Cog, to ensure that the proper permissions and
rules are in place for the use of the command, and to instruct Cog how
to interpret and expose invocation options to the command.
