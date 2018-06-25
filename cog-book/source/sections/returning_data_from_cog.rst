Returning data from Cog
=======================

.. note:: If you are using ruby or python to write your commands check out
    `cog-rb <https://github.com/cog-bundles/cog-rb>`__ and
    `pycog <https://github.com/cog-bundles/pycog>`__. They both provide
    tools to make outputting data a bit easier

Returning data from a command in Cog is pretty easy. The simplest method
is to just print a string. In ruby, ``puts("Hello, World")``. Then Cog
will print, "Hello, World".

For more granular control there are a number of output markers you can
specify to let Cog know what you want done with your output. The two
most common are ``JSON`` and ``COG_TEMPLATE:``.

-  JSON - If you precede your response with the string "JSON" and a
   newline, Cog will attempt to parse your response as json.

   For example printing this to stdout:

.. code-block:: console

  JSON
  {"foo":"bar"}

would result in Cog returning:

.. code-block:: json

  { "foo": "bar" }

.. warning:: Other than log messages, no other output can accompany json. Make
    sure any text following the JSON marker is valid json.

-  COG\_TEMPLATE: - This is used to specify a template to render. Note:
   Unlike ``JSON`` there is no newline.

   For example printing this to stdout:

.. code-block:: console

  COG_TEMPLATE: foo_template
  JSON
  {"foo":"bar"}

would tell cog to render the 'foo_template' with the json ``'{"foo":"bar"}'``.

Additionally there are several other output markers for logging to the
relay console. Log messages have the prefix ``COGCMD_`` followed by the
log level. Available log levels are: ``DEBUG``, ``INFO``, ``WARN``,
``ERR``. For example, if we wanted to log an error to the console we
would just print, ``COGCMD_ERR: And error has occured`` from our
command.

.. note:: Note that log messages may be interleaved with other output. So you
    could for example
    ``puts("some text\nCOGCMD_DEBUG: A debug statement\n some more text")``
    and Cog will happily print "some text some more text" to the user
    while logging, "A debug statement".

For the full reference of output tags see
:doc:`/references/command_output_tags`.
