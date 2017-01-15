Cog Architecture
================

A Cog chat system is composed of several interacting parts. Here, we
discuss them and how they relate.

|Cog's Architecture|

Cog
---

`Cog <https://github.com/operable/cog>`__ is the brains of the bot. It
processes chat requests and routes command invocations to Relay
instances. It also manages the logic of command pipelines. Finally, it
processes the final results of commands using chat system-specific
templates, and sends them back to the chat system.

PostgreSQL
----------

Cog stores persistent data in `PostgreSQL <http://postgresql.org>`__.
This includes information on all users, all bundles and commands, and
authorization information, including rules, permissions, roles, and
groups.

MQTT
----

Cog is built around a message bus architecture, specifically
`MQTT <http://mqtt.org/>`__. This allows it to process multiple requests
concurrently, coordinating the processing among several relatively
simple and decoupled processes. It also permits transparent distribution
of work to other nodes; all command processing is dispatched to workers
via the message bus, allowing processing to occur within the bot itself
or on any number of associated Relay processes (see below), which may
run on completely separate machines.

Relay
-----

With the exception of the embedded ``operable`` command bundle, all
command bundles run under a separate application known as a
`Relay <https://github.com/operable/relay>`__. Relay serves as an
execution environment for commands; all chat commands ultimately get
routed to a Relay through Cog in order to be executed.

This provides several benefits.

Code isolation
~~~~~~~~~~~~~~

As it is a completely separate process (potentially on an entirely
separate machine), any code running under a Relay will not have any
effect on the bot. You do not need to worry about conflicting
dependencies between a bundle and Cog breaking either one.

This isolation extends to intra-bundle conflicts as well. If you wish to
run two bundles that (for whatever reason) cannot coexist, you can run
each in their own Relay instance.

Availability
~~~~~~~~~~~~

The same bundle may be installed on multiple Relay instances, allowing
Cog to distribute command executions across multiple Relays. If one
Relay goes down, Cog will recognize this and continue executing commands
on whatever other Relays are serving the bundle.

Language Choice
~~~~~~~~~~~~~~~

Since bundles do not run inside the bot, the implementation language of
the bot does not affect the language that bundles may be written in. In
fact, bundles may be written in whatever language you choose. Relay
simply acts as a mediator between the bot and the command execution.

cogctl
------

`cogctl <https://github.com/operable/cogctl>`__ is the command-line tool
for interacting with a Cog system. It uses Cog’s REST API to perform
various administrative functions.

More information
~~~~~~~~~~~~~~~~

| :doc:`writing_a_command_bundle`
| :doc:`managing_bundles`
| :doc:`installing_and_managing_relays`
| :doc:`../references/relay_configuration`

.. |Cog's Architecture| image:: ../images/Operable_Diagram_CogArchitecture.png

|
