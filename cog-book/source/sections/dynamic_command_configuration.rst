Dynamic Command Configuration
=============================

Often, commands will need tokens, passwords, or other sensitive
information at runtime in order to do their job; managing your
`AWS <https://github.com/cogcmd/mist>`__ servers, sending a
`tweet <https://github.com/cogcmd/twitter>`__, checking your `site
availability <https://github.com/cogcmd/pingdom>`__, and many other
tasks would be impossible otherwise (at least, not without resorting to
horrible software engineering practices in your command bundles!). Cog
provides a way to deal with these important data called *dynamic command
configuration*.

.. note:: When we talk about "dynamic command configuration", this should
      not be confused with the :doc:`config.yaml <bundle_configs>` file
      that defines the commands, rules, and permissions present in each
      command bundle. That configuration is effectively static. The
      configuration we are concerned with is for the *execution* of
      individual commands.

      It’s also dynamic in the sense that it can be changed on-the-fly
      by Cog administrators, with the changes taking effect nearly
      instantaneously without restarting any applications.

Core Concepts
-------------

As detailed below, there are a few ways to go about specifying and
managing the dynamic configuration for a bundle, but the central idea is
straightforward. At the core, a dynamic configuration is a series of
key-value pairs which are injected as variables into the execution
environment of a command.

As a concrete example, let’s look at Cog’s `Pingdom
bundle <https://github.com/cogcmd/pingdom>`__. As we can
`see <https://github.com/cogcmd/pingdom/blob/ce0e124bd5dd75e2f50b1e9ca94a153d9ac87c13/config.yaml#L26-L32>`__,
the ``pingdom:check`` command expects three environment variables to be
set: ``PINGDOM_USER_EMAIL``, ``PINGDOM_USER_PASSWORD``, and
``PINGDOM_APPLICATION_KEY``. Each of these credentials are required
before we can make a properly authenticated REST API request against
Pingdom’s servers.

We can store these credentials in a simple YAML file and make it
available to Relay (we’ll talk about exactly how to do that below, but
the details aren’t important right now).

**Pingdom Dynamic Configuration.**

.. code:: YAML

      PINGDOM_USER_EMAIL: me@mycompany.com
      PINGDOM_USER_PASSWORD: supersecret
      PINGDOM_APPLICATION_KEY: abcdefghijklmnopqrstuvwxyz

Relay will inject these values into the execution environment it builds
for each command in the ``pingdom`` bundle. Commands can then access
them as environment variables (e.g. ``ENV['PINGDOM_USER_EMAIL']`` in
Ruby, ``os.environ['PINGDOM_USER_EMAIL']`` in Python, etc.)

.. warning:: Each command in a bundle will receive the same dynamic configuration
    environment. There is not currently a way to cause one command to
    receive one set of variables while another receives a different set.

.. caution:: Any keys starting with the prefixes ``COG_`` or ``RELAY_`` will be
    logged by Relay and ignored.

Layers
~~~~~~

Cog allows you to refine the values of these dynamic configurations
based on the room the command is invoked from, the user that invokes the
command, or a combination of both. For example, this would allow you to
configure the `twitter <https://github.com/cogcmd/twitter>`__ bundle to
tweet from a special support account when invoked from your ``#support``
Slack channel, but from your main company account when called from your
``#marketing`` channel.

All bundles can have a "base" configuration layer, which defines (in the
absence of any additional layering) the key-value pairs that will be
used for command invocations in general. The YAML file above could
define the base layer for the ``pingdom`` bundle. If you don’t require
any room- or user-specific customizations, this is the only layer you
really need to care about; in fact, you can act as though layers don’t
even exist.

On top of this base, a "room" layer can be overlaid using a merge
strategy. Any keys in common will take their values from the room layer,
while any keys only mentioned in the base will take their values from
that layer. While there is only one "base" layer, each bundle can have
any number of room layers, named for a room in their chat client. In our
Twitter example above, we would have a "room/support" layer, and a
"room/marketing" layer. Whenever a ``twitter`` bundle command was
invoked from one of those rooms, the appropriate layer would be put into
play.

Finally, the same situation applies for "user" layers. If Alice should
only ever tweet from a particular account, the appropriate credentials
could be put into a "user/alice" layer (assuming her Cog username is
"alice").

.. note:: Since different chat clients can have different conventions, Cog
    normalizes names by lowercasing them. Thus, the room layer for your
    \\"Operations\\" room would be \\"room/operations\\".

.. note:: Early in processing a request, Cog resolves a user’s chat handle to
    that person’s Cog username, and this is what is used to determine
    the appropriate user configuration layer to apply.

Let’s look at a basic example of how this would work in practice. Let’s
say we have a ``widget:widget`` command that we want to configure. For
it’s base configuration we’ll use this:

**base.**

.. code:: YAML

    WIDGET_FOO: base
    WIDGET_BAR: base
    WIDGET_BAZ: base

(I leave it to your imagination what exciting things a ``widget``
command could do with such configuration values.)

If this command is invoked from our ``#ops`` Slack channel, we’ll
override a few values:

**room/ops.**

.. code:: YAML

    WIDGET_BAR: ops
    WIDGET_BAZ: ops

Finally, if Alice invokes the command, we’ll add one more refinement:

**user/alice.**

.. code:: YAML

    WIDGET_BAZ: alice

Now, if Bob runs this command from the ``#engineering`` channel, that
invocation will receive just the base configuration values, because we
have defined neither a ``room/engineering`` layer, nor a ``user/bob``
layer.

If Bob runs this command from the ``#ops`` channel, however, this is
what the command will receive in its environment:

**base + room/ops.**

.. code:: YAML

    WIDGET_FOO: base
    WIDGET_BAR: ops
    WIDGET_BAZ: ops

As you can see, ``WIDGET_BAR`` and ``WIDGET_BAZ`` have been overridden,
but ``WIDGET_FOO`` takes it’s value from the base configuration. Had we
added a value for ``WIDGET_FOO`` to our ``room/ops`` layer, though, that
value would have been used here.

Now, when Alice runs this command from ``#engineering``, her invocation
will receive this set of values:

**base + user/alice.**

.. code:: YAML

    WIDGET_FOO: base
    WIDGET_BAR: base
    WIDGET_BAZ: alice

There is no ``room/engineering`` layer in place, so we still have the
``WIDGET_BAR`` value from our base layer, but the ``user/alice`` layer
has been overlaid.

If Alice runs the command from ``#ops``, all three layers will be in
effect:

**base = room/ops + alice.**

.. code:: YAML

    WIDGET_FOO: base
    WIDGET_BAR: ops
    WIDGET_BAZ: alice

How To Manage Dynamic Configuration Values
------------------------------------------

There are currently two ways to manage dynamic configuration values. The
default method involves placing dynamic configuration YAML files on the
Relay host (either manually, or via the automation tooling of your
choice). The alternative allows Cog to centrally manage the
configurations on your behalf.

Manual Management of Dynamic Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Under manual management, a Relay will look in a directory tree to find
YAML files containing layered dynamic configuration values. The layers
will be merged as described above (``base``, then ``room``, then
``user``) and injected into the execution environment. As the files are
consulted on each command invocation (rather than cached), any changes
to the files will take effect on the next invocation of a command. This
is a tiny bit slower compared to caching the contents but ensures
commands are always run with the latest configuration.

To enable this mode, Relay must be told where your configuration files
will reside by setting the :ref:`RELAY_DYNAMIC_CONFIG_ROOT<relay_dynamic_config_root>`
configuration. If you are changing this value, you will need to restart
Relay for it to take effect.

Within the ``RELAY_DYNAMIC_CONFIG_ROOT`` directory, there should be a
directory for each bundle that needs dynamic configuration. Each of
these bundle directories will contain one or more YAML files (with
either a ``*.yaml`` or ``*.yml`` extension), with each file
corresponding to an individual layer. The naming conventions are as
follows:

-  base configuration layer: ``config.yaml``, always.

-  room layers: ``room_${LOWERCASE_ROOM_NAME}.yaml``. If desired, 1-on-1
   interactions with Cog can be configured with a ``room_direct.yaml``
   file.

-  user layers: ``user_${LOWERCASE_COG_USERNAME}.yaml``

In the example directory tree below (which assumes a
``RELAY_DYNAMIC_CONFIG_ROOT`` of ``/relay-config``), we have the
`heroku <https://github.com/cogcmd/heroku>`__ bundle with a single base
configuration, the `pingdom <https://github.com/cogcmd/pingdom>`__
bundle with a base layer, an "ops" room layer, a 1-on-1 direct chat room
layer, and a user layer for "chris". Finally, the
`twitter <https://github.com/cogcmd/twitter>`__ bundle has a single base
configuration layer.

::

  |relay-config
  ├── heroku
  │   └── config.yaml
  ├── pingdom
  │   ├──config.yaml
  │   ├── room_ops.yaml
  │   ├── room\_direct.yaml
  │   └──user\_chris.yaml
  └── twitter └── config.yaml

.. note::
    *About Relays*

    - :doc:`installing_and_managing_relays`
    - `Annotated relay.conf <https://github.com/operable/go-relay/blob/master/example_relay.conf>`__

Cog-managed Dynamic Configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While manually-managed dynamic configuration is simple, it can be
cumbersome if you run multiple Relays, or do not have filesystem access
to your Relay (as is the case with `Hosted
Cog <https://cog.operable.io>`__). In this case, you can submit your
dynamic configuration layer files to Cog and it will distribute the
values to your Relays as appropriate.

By default your Relay(s) already supports managed dynamic config, but
you can always disable it by setting <RELAY\_MANAGED\_DYNAMIC\_CONFIG>>
to ``false``. Managed Relays check in with their Cog server periodically
(every 5 seconds by default; see
:ref:`RELAY_MANAGED_DYNAMIC_CONFIG_INTERVAL<relay_managed_dynamic_config_interval>` ) to refresh their
configuration data.

.. note:: Currently, managed configuration mode requires each individual Relay
    to be configured as such; it is not a centrally-enabled option.
    Future versions of Cog and Relay may change this.

The easiest way submit configuration layers to Cog is by using
``cogctl``, which in turn uses Cog’s REST API.

.. warning:: These commands and the API they are built on *only* work for the
    Cog-managed configuration. They will not have access to
    manually-managed configuration files on Relay hosts. The manual
    process is, well, *manual*.

Adding a base layer of dynamic configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code:: shell

    $ cogctl bundle config create pingdom ~/path/to/config.yaml --layer=base
    Created base layer for 'pingdom' bundle

Here, the ``--layer`` option is not required; if not specified, "base"
is always the default.

Adding other layers is similar:

.. code:: shell

    $ cogctl bundle config create pingdom ~/path/to/room_ops.yaml --layer=room/ops
    Created room/ops layer for 'pingdom' bundle
    $ cogctl dynamic-config create pingdom ~/path/to/user_chris.yaml --layer=user/chris
    Created user/chris layer for 'pingdom' bundle

Showing the layers that exist
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can list all layers that are currently in place for a given bundle.

.. code:: shell

    $ cogctl bundle config layers pingdom
    base
    room/ops
    user/chris

For any given layer, you can see the configuration that will be used.

.. code:: shell

    $ cogctl bundle config info pingdom base
    PINGDOM_USER_PASSWORD: "secret_dont_tell"
    PINGDOM_USER_EMAIL: "cog@operable.io"
    PINGDOM_APPLICATION_KEY: "blahblahblah"

Again, if you do not specify a layer, "base" is assumed. That is,
``cogctl bundle config info pingdom`` is equivalent to the above command.

You can also see other layers:

.. code:: shell

    $ cogctl bundle config info pingdom room/ops
    PINGDOM_USER_PASSWORD: "ops4life"
    PINGDOM_USER_EMAIL: "cog_ops@operable.io"
    PINGDOM_APPLICATION_KEY: "opsblahblahblah"

.. note::
    | The ``cogctl bundle config info`` subcommand returns the contents
      of *only* the specified layer; it does not show you the effective
      configuration that might be injected into a command’s execution
      environment. You are shown exactly what was uploaded when you ran
    |
    | cogctl bundle config create $BUNDLE $PATH\_TO\_CONFIGURATION\_FILE --layer=$LAYER
    |
    | not the result of overlaying multiple layers on top of each other.

Deleting Configuration Layers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Configuration layers can be deleted individually

.. code:: shell

    $ cogctl bundle config delete pingdom
    Deleted 'base' layer for bundle 'pingdom'
    $ cogctl bundle config delete pingdom room/ops
    Deleted 'room/ops' layer for bundle 'pingdom'

(As before, not specifying a layer defaults to operating on the ``base``
layer.)

Note that by deleting the "base" layer only deletes the base layer; any
room or user layers will still be applied. If you wish to remove *all*
dynamic configuration, you must remove each layer individually. The
following pipelines may be useful:

.. code:: shell

    # Remove ALL layers
    cogctl bundle config layers pingdom | xargs -n1 cogctl bundle config delete pingdom

    # Remove only room layers
    cogctl bundle config layers pingdom | grep "room/" | xargs -n1 cogctl bundle config delete pingdom

    # Remove only user layers
    cogctl bundle config layers pingdom | grep "user/" | xargs -n1 cogctl bundle config delete pingdom
