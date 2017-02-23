Building and Running Cog from Scratch
=====================================

To run Cog you’ll need to start three separate processes: Postgres,
Relay and Cog itself, all of which will require a few dependencies.

-  Postgres 9.4+

-  Erlang 18+

-  Elixir 1.3+

-  Go 1.6+

-  Docker 1.10.3+

-  GCC

Downloading and installing Postgres 9.4+ should be straight forward.
Take a look at `their download
page <https://www.postgresql.org/download/>`__ for more details.

Next, let’s build Relay. You’ll need to install Go 1.6+ and Docker
1.10.3+. Why do we still need Docker? Bundles have the option to define
an image on Docker Hub in which to run the command. So, Relay needs to
know how to download those images and start containers to run some
commands.

Download the source in your ``$GOPATH`` and build it.

.. code:: bash

    mkdir -p $GOPATH/src/github.com/operable
    git clone git@github.com:operable/go-relay.git $GOPATH/src/github.com/operable/go-relay
    cd $GOPATH/src/github.com/operable/go-relay
    make

You should have an executable in ``_build`` ready to go. We’ll come back
to it in a mintue.

Now, to build Cog. Cog is written in Elixir, which means you’ll need to
install both Erlang 18+ and Elixir 1.3+. You can find more information
about how to install Elixir on their `installation
guide <http://elixir-lang.org/install.html>`__. Once you have Elixir
installed run the following to clone the Cog repo, download deps, setup
the database, compile and run Cog.

.. code:: bash

    git clone git@github.com:operable/cog.git
    cd cog
    make setup run

You’ll notice that the ``run`` target crashed as we didn’t provide a
``SLACK_API_TOKEN`` environment variable. To fully configure Cog and
Relay we’ll need to set a few environment variables. If you need more
customization than is explained in this guide checkout the full listing
of environment variables and their descriptions for both
:doc:`../references/cog_server_configuration` and :doc:`../references/relay_configuration`.

For now let’s just provide the minimum to get things up and running. For
Cog, we’ll just need to set ``COG_SLACK_ENABLED`` and
``SLACK_API_TOKEN`` as everything else has a sensible default. You can
get a ``SLACK_API_TOKEN`` for your bot by creating a `new bot
integration <https://my.slack.com/services/new/bot>`__. So let’s try
running Cog again, now with our token exported.

.. code:: bash

    export COG_SLACK_ENABLED=true
    export SLACK_API_TOKEN=xoxb-87931061512-notarealtokenLNjTMuxxozUo
    make run

To get Relay running, we’ll need to supply both ``RELAY_ID`` and
``RELAY_COG_TOKEN`` which are used to both identify our Relay and allow
it to connect to Cog. I would recommend using a uuid for ``RELAY_ID``
and a random string for the ``RELAY_COG_TOKEN``. If you have ``uuid``
and ``openssl`` installed you could use the following commands like
these to generate them. After, exporting those variables we can run the
run the binary we previously built.

.. code:: bash

    export RELAY_ID=`uuid` && echo $RELAY_ID
    export RELAY_COG_TOKEN=`openssl rand -hex 12` && echo $RELAY_COG_TOKEN
    export RELAY_DYNAMIC_CONFIG_ROOT=/tmp/dynamic_configs
    _build/relay

You’ll see a warning about a missing configuration file, which you can
ignore since we’re not using one.

Ok, so now we have both Cog and Relay up and running, but they aren’t
actually aware of each other yet. Because Cog was designed to be run
with multiple Relays on multiple hosts, we need to tell Cog about our
Relay before it can connect. It’s worth noting, that in this example
we’ve bound to ``localhost`` so certain features like enforcing a
matching ``RELAY_TOKEN`` are disabled. But, to add a Relay to Cog, we
need to build and run Cogctl.

Cogctl is written in Python 3, but can be compiled to a standalone,
self-contained binary. Setting up a Python development environment is
beyond the scope of this document, but up-to-date instructions can be
found in the README of the `cogctl repository <https://github.com/operable/cogctl>`__.

Once you build the binary, you’ll have a ``cogctl`` executable in the
``dist`` directory of your ``cogctl`` checkout. You can run this from
its current location, or move it anywhere you like.

Ok, now we just need to bootstrap Cog and create a record for our Relay.
Here’s a snippet:

.. code:: bash

    ./cogctl bootstrap http://localhost:4000
    ./cogctl relay create my-relay $RELAY_ID $RELAY_COG_TOKEN

And now you should be in business. But there’s one last step we need to
take care of before you can run commands. You’ll need to create an
account for yourself. Copying this run the Docker-based walkthrough, run
this:

.. code:: bash

    ./cogctl user create patrick \
      --first-name="Patrick" \
      --last-name="Van Stee" \
      --email="patrick@operable.io" \
      --password="supersecret"

    ./cogctl chat-handle create patrick slack vanstee

    ./cogctl group add cog-admin patrick

And now you should be all set. For a quick walkthrough of installing
your first bundle and running a command, jump back up to the section
titled "Installing and Configuring a Bundle."
