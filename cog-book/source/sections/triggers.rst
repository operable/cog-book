Triggers
========

*Teach Cog to respond to HTTP requests!*

Cog is a great tool for automating tasks from inside your chat client.
However, Cog not only responds to interactions from chat, but from
external services as well, expanding what you can do and automate with
Cog. Triggers allow Cog to kick off entire command pipelines in response
to HTTP requests.

Cog provides a REST API for creating, showing, updating and deleting
triggers; the ``cogctl`` executable and ``operable:trigger`` chat
commands may also be used.

.. _anatomy_of_a_trigger:

Anatomy of a Trigger
--------------------

--- A trigger is effectively a Cog command pipeline that is paired with
a unique URL, along with a few pieces of metadata that affect how the
trigger executes.

-  ``id`` **UUID, generated** A UUID reference to the trigger

-  ``name`` **String, required** A unique name for the trigger. This can
   be used in tools like ``cogctl`` to interact with the trigger.

-  ``pipeline`` **String, required** A complete Cog command pipeline,
   including `redirect destinations <#Redirecting Pipeline Output>`__.
   This is what will execute when the trigger is activated. Anything you
   can do in chat is fair game here.

-  ``description`` **String, optional** A human-readable free-form text
   string that describes the trigger; this is your documentation.

-  ``as_user`` **String, optional** The Cog username of the user the
   pipeline should execute as. If not specified, a standard Cog
   authentication token is required in the request, and the pipeline
   will execute as the owner of that token. If the trigger is configured
   with a user and a request with a token is received, the configured
   user takes precedence over the token owner.

-  ``timeout_sec`` **Integer, optional** The number of seconds Cog will
   wait for pipeline execution to finish. If the pipeline is still
   processing when the timeout expires, an HTTP ``202 Accepted``
   response is returned to the requestor, indicating successful receipt
   of the request. The pipeline may fail afterward, though. However, a
   unique request ID is sent back in the body of the 202 response.
   Currently, this can be used to identify audit log messages pertaining
   to the pipeline execution; eventually there will be a proper
   interface for this use case.

   ::

       Defaults to 30 seconds.

-  ``enabled`` **Boolean, optional** An enabled trigger executes its
   pipeline when triggered; a disabled one does not. By default, all
   triggers are created in the enabled state. You can toggle this if you
   wish to disable a trigger without deleting it. A request sent to a
   disabled trigger’s invocation URL (see below) will immediately return
   an HTTP 422.

-  ``invocation_url`` **URL, generated** HTTP ``POST`` requests sent to
   this URL will trigger the pipeline.

.. _manipulating_triggers:

Manipulating Triggers
---------------------

--- While there is a REST API for manipulating triggers, you can also
use ``cogctl`` and the ``operable:trigger`` chat command.

Create a Trigger
~~~~~~~~~~~~~~~~

**Chat.**

.. code:: shell

    cogctl trigger create hello-world \
      'echo "Hello World" > chat://#general' \
      --as-user='bobby_tables' \
      --description='Hello World, because I did not want to do Fibonacci' \
      --enabled \
      --timeout=5

Each option flag corresponds to one of a trigger’s required or optional
attributes. Unspecified optional attributes will receive their default
values.

Show a Trigger
~~~~~~~~~~~~~~

**Chat.**

.. code:: shell

    cogctl triggers info hello-world

Supply the ``name`` of the trigger you want information on

Showing all Triggers
~~~~~~~~~~~~~~~~~~~~

**Chat.**

.. code:: shell

    cogctl trigger

This will list all triggers, showing their name, pipeline, and if they are enabled.

.. _update_a_trigger:

Update a Trigger
~~~~~~~~~~~~~~~~

**Chat.**

.. code:: shell

    cogctl trigger update hello-world \
      --pipeline='echo "Hello World" *> chat://#dev chat://#ops'

The trigger being updated is specified by name; the allowed options are
the same as in ``cogctl trigger create``; any values specified
overwrite the values currently in the system, leaving others unchanged.
In this example, we are only changing the pipeline that is executed.

Note that you can also change the name of a trigger. Its UUID will
remain the same, though, as will its ``invocation_url``.

Deleting a Trigger
------------------

**Chat.**

.. code:: shell

    cogctl triggers delete hello-world

To delete a trigger, specify its name.

Enabling / Disabling a Trigger
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

**Chat.**

.. code:: shell

    cogctl trigger update hello-world --disable
    cogctl trigger update hello-world --enable


.. _invoking_a_trigger:

Invoking a Trigger
------------------

When a trigger is created, an invocation URL for that trigger is
created. HTTP ``POST`` requests sent to this URL will initiate execution
of the trigger’s pipeline.

It should be noted that the invocation URL is served on a different port
than the rest of Cog’s REST API; while you might view information about
a specific trigger with a ``GET`` request to

``http://cog.mycompany.com:4000/v1/triggers/cd3ba1dc-b807-4b52-8acc-75c3f4e56b88``

you might invoke that same trigger with a ``POST`` to

``http://cog.mycompany.com:4001/v1/triggers/cd3ba1dc-b807-4b52-8acc-75c3f4e56b88``

This is to allow fine-tuning of firewall policies so you can restrict
outside access to just the pipeline triggers and not the entire Cog API.
You should use the invocation URL that Cog gives you, rather than
constructing one on your own.

The ports for the API and trigger execution can be specified with the
:ref:`COG_API_PORT <cog_api_port>` and :ref:`COG_TRIGGER_PORT <cog_trigger_port>` environment
variables, respectively.

.. _initial_calling_environment_for_trigger_invoked_pipelines:

Initial Calling Environment for Trigger-Invoked Pipelines
---------------------------------------------------------

Each command in a Cog pipeline receives a ``cog_env`` ("Cog
Environment"), a data structure containing output from previous
commands. This is what variable binding in pipelines works off of, for
instance. The ``cog_env`` is available in its entirety within the
executing command, as well. The content of the ``cog_env`` is dependent
on the output of the command preceding it, just as what one command in a
shell pipeline receives on ``STDIN`` depends on what the preceding
command sent to ``STDOUT``.

The first command in a pipeline presents a bit of a wrinkle, in that
there aren’t any preceding commands to generate any data for
``cog_env``. For triggered pipelines, Cog will construct a special
``cog_env`` using data from the triggering request. It will be a map
with the following keys:

-  ``trigger_id`` The UUID of the trigger being executed

-  ``headers`` A map of lower-cased HTTP header names to values. The
   value of a repeated header is a list of all values; the value of a
   unique header is just the given (non-list) value.

-  ``query_params`` A map of any query parameters provided

-  ``body`` The parsed JSON request body

-  ``raw_body`` The request body as it was received, as an unparsed JSON
   string. This is provided to allow commands to perform e.g.,
   cryptographic validation of requests.

This generated ``cog_env`` is provided to the first command in the
pipeline, allowing it to perform variable binding (which is not possible
with chat-initiated pipelines, which effectively start with an empty
``cog_env``).

By providing the HTTP request in the ``cog_env``, it makes it possible
to have dynamic triggered pipelines that respond to incoming data.

It should be noted that trigger requests do not *require* a body, query
parameters, or any special headers (apart from ``content-type``,
``accept``, or ``authorization`` if the trigger is not configured to run
as a specific user). If present, however, they are passed on to the
pipeline, and can be used to customize execution as you see fit.

Response Disposition In Triggers
--------------------------------

The way that triggered pipelines handle their output is a bit more
complex than pipelines initiated from chat. Part of this stems from the
fact that chat-based interactions are essentially asynchronous. If you
execute a pipeline from chat, you don’t need an immediate response;
you’ll just wait to see in your chat window what Cog’s reply will be.
HTTP, of course, is different; Cog has to finalize the request
processing by sending a response. Now, Cog *could* just always send an
HTTP ``202 Accepted`` response acknowledging receipt of the triggering
request, but that would reduce the utility of triggers.

Another wrinkle is that chat-initiated pipelines operate under the
assumption that you’re going to want to see the output *in chat* (it’s a
poor chat-ops bot that doesn’t reply in chat, after all). However, in
the interests of modularity, the HTTP adapter that allows Cog to listen
for HTTP requests only handles HTTP requests and doesn’t know anything
about chat systems at all. Even though a pipeline isn’t initiated in
chat, you’re still probably going to want to see the output in chat.
After all, that’s where the people are!

So, the nature of dealing with HTTP requests in a chat bot presents some
fundamental differences in how to deal with pipeline output and
presenting it to users. However, Cog provides a few "switches" you can
use to manipulate exactly how Cog behaves. We’ll take a look at the
redirection destinations you supply in the trigger’s pipeline, as well
as the trigger’s ``timeout_sec`` attribute. Finally, we’ll see how
pipeline execution errors are handled for triggers.

.. _redirect_destinations_in_triggered_pipelines:

Redirect Destinations in Triggered Pipelines
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As you know, there are a few ways you can specify :doc:`output destinations
for a pipeline <redirecting_pipeline_output>`. Let’s take a look at a
few scenarios with a triggered pipeline to see how these behave.

If you don’t want any output from the trigger to go to chat, and only
want it in the HTTP response body, you don’t need to supply any redirect
destinations. Recall that Cog pipelines send their output back to where
the input came from. In chat, that means the chat room in which you
typed the pipeline; for HTTP, that means sending it back to the HTTP
requestor.

That is, if you triggered the pipeline ``echo "Hello World"``, you’d get
``"Hello World"`` in the HTTP response body.

Recall also that you can explicitly cause this same behavior by using
the :ref:`here redirect alias <here_alias>`. In this case,

**Cog.**

.. code:: text

    echo "Hello World" > here

would behave exactly as

**Cog.**

.. code:: text

    echo "Hello World"

(The :ref:`me redirect alias <me_alias>`, however, is not available for
triggered pipelines.)

Receiving output in the response body may be useful for authenticated
remote execution of pipelines (i.e. using Cog as a workflow execution
engine without the chat system). It can also be useful for
troubleshooting webhook execution (e.g., examining recent webhook
deliveries in Github’s interface).

Many times, of course, you’ll want output in chat. This is where Cog’s
:ref:`chat:// URL redirect destinations <chat_URLs>` come into play. Since
the HTTP adapter knows nothing of chat, you must use the full URL-style
redirect to instruct Cog to pass handling of the output to the currently
configured chat adapter. Naturally, multiple redirects are available for
triggered pipelines, as they are for chat-initiated pipelines. The
pipeline

**Cog.**

.. code:: text

    echo "Hello World" *> chat://#general chat://@brent

would send output to your ``#general`` Slack channel, as well as
directly to ``@brent``. Note in this example, that we are *not* sending
the output back to the HTTP response (do do that as well, we would need
to add ``here`` to our list of destinations). If you choose not to
include the HTTP response in your destinations list, the HTTP adapter
will finalize the response with an HTTP ``204 No Content``.

Remember: if you want output to go to chat from a triggered pipeline,
you *must* use the full ``chat://`` URL destination form. Using just a
bare room or user (e.g. ``#general``, ``@brent``) is an error.

.. _trigger_timeouts:

Trigger Timeouts
~~~~~~~~~~~~~~~~

The ``timeout_sec`` attribute of a trigger basically specifies how long
Cog will wait for the pipeline to complete execution before finalizing
its HTTP response. Note that it is purely about the HTTP response
handling; it does *not* impose an overall limit on how long the pipeline
execution itself should take.

Let’s say you’re setting up a Github webhook to trigger a Cog pipeline.
After reading their documentation, you’ll discover they require a
response within 30 seconds of sending a webhook request. If you want the
output of the pipeline to be included in the HTTP response, this is how
long you can afford to wait for that output. If the timeout expires but
the pipeline is still executing, the HTTP adapter will have to finalize
its response with an HTTP ``202 Accepted`` status; however, the pipeline
execution will still continue in the background.

Depending on the needs of your trigger, you can customize its timeout as
needed. Github, as we have seen, imposes a 30 second timeout; other
services may have timeouts that are more stringent or more lenient. Also
remember that the trigger’s timeout is really only important if you care
about receiving output in your response. If you’re happy with a
"fire-and-forget" mode of operation, you can just set timeout to 1 (the
lowest legal timeout) and essentially receive HTTP ``202 Accepted``
responses for all the trigger’s requests.

Currently, however, you must specify *some* non-zero timeout. Also keep
in mind that Cog currently imposes an execution timeout of 60 seconds on
any individual command invocation execution. That is, if it takes longer
than 60 seconds for any single command in a pipeline to execute, the
entire pipeline will be terminated at that point. There is currently no
"global" timeout on the entire pipeline, though. You could have a
pipeline chain of 100 commands, and as long as no one command took more
than a minute to execute, the entire pipeline would run (for over an
hour and a half).

.. _errors_and_empty_pipelines:

Errors and "Empty" Pipelines
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As we’ve seen, Cog will wait for ``timeout_sec`` seconds to see what the
output of the pipeline execution will be. This applies both to successes
as well as to errors.

If a pipeline fails within the timeout period, however, Cog will send
the resulting error message back in the HTTP response with a
``500 Internal Server Error`` status code. In this situation, the error
is **only** sent to the HTTP response. Even if ``chat://`` destinations
are specified in the trigger’s pipeline, they will not receive any
message. This is to prevent seemingly disconnected error messages from
cluttering your chat agent. Failures can be seen in the audit log,
however. In the future, we will be providing more ways to examine
failure cases like this.

The other situation where output will not go to chat destinations is
when a pipeline "dries up" partway through. Recall that Cog commands
receive a ``cog_env`` data structure encapsulating the output of the
previous pipeline command. It is possible (and legitimate) for some
pipeline commands to return an empty ``cog_env`` to the following
command (for instance, when a ``filter`` command actually filters out
*all* data flowing through the pipeline). In this case, the pipeline
will have completed successfully, but without any meaningful output.
When this happens in a chat-initiated pipeline, Cog will reply to the
user saying
``"Pipeline executed successfully, but no output was returned"``. While
this is helpful feedback when interacting directly with a human, it
would be disorienting to see this appear in chat, seemingly in response
to nothing. As such, this is not sent to chat when coming from a
triggered pipeline.
