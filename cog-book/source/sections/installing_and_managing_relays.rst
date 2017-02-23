Installing and Managing Relays
==============================

To effectively route commands to Relay, we need to inform Cog of each
Relay and configure each Relay to communicate with Cog via the message
bus.

Configuring A New Relay
-----------------------

Cog needs at least one Relay in order to deploy command bundles and
execute commands. Configuring Cog to know about a new Relay instance is
a simple three step process.

1. Pick a secret word or phrase shared between Cog and the new Relay
   instance. Cog’s API refers to this secret as a *token*.

2. Use ``cogctl`` to tell Cog about the Relay and its secret.

**Configuring a new relay.**

You'll need to create an ID for your relay (a UUID), as well as create
a shared secret (a "token") and then give these to Cog:

.. code:: bash

    $ cogctl relay create my_new_relay bd03d7f0-b670-4721-9121-c23e62583e49 "my fancy sekrit"

1. Use the ID and token from step #2 to start the Relay instance.

**Relay starting up.**

.. code:: bash

    $ RELAY_ID=bd03d7f0-b670-4721-9121-c23e62583e49 RELAY_COG_TOKEN="my fancy sekrit" relay
    INFO[2016-04-18T14:42:57-04:00] Loaded configuration file ./cog_relay.conf.
    INFO[2016-04-18T14:42:57-04:00] Relay f8e3ead2-57e0-4fb2-81e9-24bf6c104202 is initializing.
    INFO[2016-04-18T14:42:57-04:00] Docker execution engine enabled.
    INFO[2016-04-18T14:42:57-04:00] Native execution engine enabled.
    INFO[2016-04-18T14:42:57-04:00] Verifying Docker registry credentials.
    INFO[2016-04-18T14:42:58-04:00] Docker configuration verified.
    INFO[2016-04-18T14:42:58-04:00] Started 8 workers.
    INFO[2016-04-18T14:43:00-04:00] Connected to Cog host 10.10.2.12.
    INFO[2016-04-18T14:43:00-04:00] Refreshing bundles and related assets every 30s.
    INFO[2016-04-18T14:43:00-04:00] Cleaning up expired Docker assets every 5m0s.
    INFO[2016-04-18T14:43:00-04:00] Refreshing command bundles.
    INFO[2016-04-18T14:43:00-04:00] Bundle refresh complete.
    INFO[2016-04-18T14:43:00-04:00] Relay f8e3ead2-57e0-4fb2-81e9-24bf6c104202 ready.

A fully commented example ``relay.conf`` file can be found
`here <https://github.com/operable/go-relay/blob/master/example_relay.conf>`__.

.. _relays_and_relay_groups:

Relays & Relay Groups
---------------------

Once a Relay has been created it can be assigned to one or more *relay
groups*. Relay groups are merely named groups of Relays used to organize
many Relays into logical groupings.

.. note:: You can read about how Cog uses relay groups to simplify command
    bundle deployment in :doc:`managing_bundles`.

No relay groups are defined when Cog is first installed so you’ll need
to use ``cogctl`` to create at least one.

**Creating a relay group.**

.. code:: bash

    $ cogctl relay-group create my_relay_group
    Created relay group 'my_relay_group'

You can also create a relay group and assign Relays to it in a single
command, too.

**Creating a relay group with members.**

.. code:: bash

    $ cogctl relay-groups create my_newer_group my_new_relay
    Created relay group 'my_newer_group'
    Relay group 'my_newer_group' has the following relay members: my_new_relay

Members can be added or removed from a relay group at any time with
``cogctl`` 's ``relay-group add`` and ``relay-group remove`` actions.

**Adding and removing group members.**

.. code:: bash

    $ cogctl relay-group add my_relay_group my_new_relay
    Relay group 'my_relay_group' has the following relay members: my_new_relay, my_other_relay
    $ cogctl relay-group remove my_relay_group my_other_relay
    Relay group 'my_relay_group' has the following relay members: my_new_relay

Finally, you can view a detailed description of a relay group with
``cogctl`` 's ``relay-group info`` action.

**Viewing a relay group.**

.. code:: bash

    $ cogctl relay-group info my_relay_group
    Name           my_relay_group
    ID             c3d29691-dc5b-4adf-a88b-53aff0e2bfa4
    Creation Time  2016-04-19T18:55:52Z

    Relays
    NAME   ID
    my_new_relay  f8e3ead2-57e0-4fb2-81e9-24bf6c104202
    $

Now you are ready to add :doc:`managing_bundles` to your relays
in order to execute your installed commands.
