Command Environment Variables
=============================

When you send a command invocation to Cog, it can have many arguments
and options. There are also several other pieces of important metadata
that can be useful for commands to be aware of during execution. To get
these data into the actual executable running that command, we expose
them as environment variables. While libraries like
`cog-rb <https://github.com/operable/cog-rb>`__ and
`pycog3 <https://github.com/operable/pycog3>`__ provide
language-friendly abstractions to interact with these data, it can be
useful to know the details of how they are structured, in case you need
to perform some unique processing, or are writing commands in a language
where a Cog library does not yet exist.

In general, all Cog-related environment variables will be prefixed with
``COG_``.

Arguments
---------

Arguments to Cog commands are represent in much the same way as they are
in traditional UNIX shell scripting.

-  ``COG_ARGC``: the number of arguments

-  ``COG_ARGV_<N>``: The *nth* argument, starting at ``N = 0``

For example, given the notional command invocation
``my:command foo bar baz``, the executable would access the arguments
through the following environment variables:

.. code:: shell

    COG_ARGC=3
    COG_ARGV_0="foo"
    COG_ARGV_1="bar"
    COG_ARGV_2="baz"

Options
-------

As they behave like a map, options are handled a bit differently

-  ``COG_OPTS``: a comma-delimited list of all option names

-  ``COG_OPT_<NAME>``: the value of the ``NAME`` option

For example: the executable processing the invocation
``my:command --verbose --force --foo=bar`` would access the options
through the following variables:

.. code:: shell

    COG_OPTS="verbose,force,foo"
    COG_OPT_VERBOSE="true"
    COG_OPT_FORCE="true"
    COG_OPT_FOO="bar"

Note that the names given in ``COG_OPTS`` are lowercase, while the names
of all environment variables provided by Cog are all uppercase.

List-valued Options
~~~~~~~~~~~~~~~~~~~

The above model works fine for options that have scalar values. For
option values that are lists, we use an approach that is a hybrid
between the argument processing and the scalar option processing we
discussed above.

-  ``COG_OPT_<NAME>_COUNT``: The number of values for the ``NAME``
   option

-  ``COG_OPT_<NAME>_<N>``: The *nth* value of the ``NAME`` option,
   starting at ``N = 0``.

For an invocation like ``my:command --foo=one --foo=two --foo=three``,
the executable would access the values of ``foo`` with these variables:

.. code:: shell

    COG_OPT_FOO_COUNT=3
    COG_OPT_FOO_0="one"
    COG_OPT_FOO_1="two"
    COG_OPT_FOO_2="three"

.. warning:: Only scalar-valued option values will have a ``COG_OPT_<NAME>``
    environment variable. Variables pertaining to list-valued options
    will always end in either ``_COUNT`` or ``_N`` (where ``N`` is an
    integer).

General Metadata
----------------

The following variables are set for all commands.

-  ``COG_BUNDLE``: The name of the bundle the current command is a
   member of.

-  ``COG_CHAT_HANDLE``: the chat handle of the user executing the
   command. This is the bare handle; if I am ``@user`` in Slack, the
   value will be just ``"user"``

-  ``COG_COMMAND``: The name of the current command being executed. Does
   *not* include the bundle; that is, when executing the command
   ``twitter:tweet``, for example, ``COG_COMMAND`` will equal
   ``"tweet"``.

-  ``COG_INVOCATION_ID``: a unique ID string identifying the specific
   invocation within a pipeline stage .

-  ``COG_INVOCATION_STEP``: the string ``"first"`` if this is the first
   invocation of a command for a given stage of a pipeline, the string
   ``"last"`` if it is the last invocation, and unset if any
   intermediate invocation. If there is only a single invocation to be
   run in a given stage, the value will be ``"last"``.

-  ``COG_PIPELINE_ID``: a unique ID string assigned to each pipeline.
   All commands in a given pipeline will receive the same value.

-  ``COG_ROOM``: the chat room where the command was invoked. This is
   the bare room name; if it was executed in the ``#general`` channel in
   Slack, the value would be just ``"general"``. For 1-on-1
   interactions, this will be the string ``"direct"``.

-  ``COG_SERVICE_TOKEN``: a unique token for accessing Cog’s service
   infrastructure.

-  ``COG_SERVICES_ROOT``: Host and port for accessing Cog’s service
   infrastructure.

All other environment variables (e.g., ``PATH``, ``USER``, etc.) are
inherited from the Relay process.
