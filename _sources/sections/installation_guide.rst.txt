.. _installation_guide:

Installation Guide
==================

So, you’re ready to get in there and give Cog a shot? Well, you’re in
luck. We’ve made it pretty straight forward to get up and running
whether you want to use our recommended Docker Compose configuration or
manually build and run Cog on your own. In this guide, we’ll walk you
through:

-  Installing and Running Cog with Docker Compose

-  Connecting Cog to Slack

-  Installing and Configuring a Bundle

-  Running a Command Pipeline

If you don’t want to use Docker Compose to install Cog or you want to
connect to HipChat instead of Slack, take a look at the alternative
sections below:

-  :doc:`building_cog_from_scratch`

-  :ref:`installation_guide_hipchat`

.. note:: If you have any trouble during this guide or just want to
          ask a question, head on over to the `Cog Public Slack
          channel <http://slack.operable.io>`_ to get help from the core team, or even the author of this guide.

.. _installation_guide_docker_compose:

Installing and Running Cog with Docker Compose
----------------------------------------------

We’ve provided a set of docker-compose files for running and configuring
Cog: ``docker-compose.yml``, ``docker-compose.common.yml`` and
``docker-compose.override.slack_example.yml`` for running and
configuring Cog. To run the images specified in the
``docker-compose.yml`` you’ll need to have both Docker and Docker
Compose installed. If you’d rather manually build and install Cog, see the section titled, :doc:`building_cog_from_scratch`.

First, make sure you have Docker and Docker Compose installed. If you
haven’t installed Docker, we recommend using `Docker for
Mac <https://www.docker.com/products/docker>`__ (or the native
application for your OS), but you can also use ``docker-machine`` with a
bit of configuration. Then, you’ll also need to install docker-compose.
You can follow any of the directions posted on `Docker Compose’s
installation guide <https://docs.docker.com/compose/install/>`__.

Next, we’ll need to grab the ``docker-compose.yml``,
``docker-compose.common.yml`` and
``docker-compose.override.slack_example.yml`` files from the Cog repo.

If you’d rather connect Cog to HipChat, skip down to the section titled
`Connecting Cog to HipChat`_.

.. code-block:: bash

    curl -o docker-compose.yml \
      https://raw.githubusercontent.com/operable/cog/1.0.0/docker-compose.yml

    curl -o docker-compose.common.yml \
      https://raw.githubusercontent.com/operable/cog/1.0.0/docker-compose.common.yml

    curl -o docker-compose.override.yml \
      https://raw.githubusercontent.com/operable/cog/1.0.0/docker-compose.override.slack_example.yml

The ``docker-compose.yml`` defines which images to run and how they’ll
talk to each other, while ``docker-compose.common.yml`` and
``docker-compose.override.yml`` set values for the environment variables
passed into each container. The default ``docker-compose.override.yml``
has everything you’ll need to start a working Cog instance. But, we
recommend that you set each environment variable starting with
``BOOTSTRAP`` to automatically create an admin user for yourself upon
startup.


.. _installation_guide_slack:

Connecting Cog To Slack
-----------------------
Ok, we’re almost ready to start Cog, but one last thing we’ll need is a
bot token so Cog can connect to our Slack channel. Head over to the `New
Bot Integration Page <https://my.slack.com/services/new/bot>`__, create
a new bot, and copy the newly generated token; it should look something
like ``xoxb-87931061512-4m0DshC79h8tLNjTMuxxozUo``.

While you are over in Slack making your bot, add a cute Cog avatar, too.
Find a Cog avatar and other Cog branded goodies in the `Operable + Cog
Brand
Folder <https://drive.google.com/open?id=0B9shLHjT25r-SkhqSTU2MG05dG8>`__

You’ll also need to export a ``COG_HOST`` variable. This is not a proper
:doc:`../references/cog_server_configuration`
but one specifically for use with this ``docker-compose`` example. This
is the host that the Cog API will be made available at. Set this to
point to your Docker host. If you’re using `docker-machine for
example <https://docs.docker.com/machine/>`__, this would suffice:

**Export Environment Variables.**

.. code-block:: bash

    export SLACK_API_TOKEN=<your_token>
    export COG_HOST=$(docker-machine ip default)

Now it’s time to run ``docker-compose``. From the same directory
containing the ``docker-compose.yml``, run the following with the bot
token you just generated.

.. code-block:: bash

    export SLACK_API_TOKEN=xoxb-87931061512-notarealtokentLNjTMuxxozUo
    docker-compose up

You should see Docker downloading and starting images for Cog, Relay and
a database. This might take a while, but once it’s done starting up and
has connected you should start seeing logs like the following:

.. code-block:: console

  cog\_1 \| 2016-10-07T00:38:51.0504 (Cog.BusEnforcer:60) [info] Allowed connection for Relay 00000000-0000-0000-0000-000000000000

For the last step, let’s check and see if our bot is available in the
chat room. Open up Slack and try the following command. Keep in mind
that you’ll have to invite the bot to whatever room you first message it
from.

.. code-block:: chat

    vanstee 11:03AM @cog help
    cog     11:03AM @vanstee: I'm terribly sorry, but either I don't
                    have a Cog account for you, or your Slack chat handle has not been registered.
                    Currently, only registered users can interact with me.

                    You'll need to ask a Cog administrator to fix this situation and to register your Slack handle.

That’s because Cog doesn’t respond to people it doesn’t know about.

Now you can move on to the section titled
`Creating a User and Running a Command`_ where we’ll create a Cog user associated with your Slack user
and give it some permissions, so you can start running some commands.

.. _installation_guide_hipchat:

Connecting Cog to HipChat
-------------------------

Ok, so you’ve already installed Docker and Docker Compose. Next, we’ll
need to grab the ``docker-compose.yml``, ``docker-compose.common.yml``
and ``docker-compose.override.hipchat_example.yml`` files from the Cog
repo.

.. code-block:: bash

    curl -o docker-compose.yml \
      https://raw.githubusercontent.com/operable/cog/1.0.0/docker-compose.yml

    curl -o docker-compose.common.yml \
      https://raw.githubusercontent.com/operable/cog/1.0.0/docker-compose.common.yml

    curl -o docker-compose.override.yml \
      https://raw.githubusercontent.com/operable/cog/1.0.0/docker-compose.override.hipchat_example.yml

The ``docker-compose.yml`` defines which images to run and how they’ll
talk to each other, while the ``docker-compose.override.yml`` sets
values for the environment variables passed into each container. The
default ``docker-compose.override.yml`` has everything you’ll need to
start a working Cog instance. But, we recommend that you set each
environment variable starting with ``BOOTSTRAP`` to automatically create
an admin user for yourself upon startup.

Ok, we’re almost ready to start Cog, but one last thing we’ll need is a
new HipChat user for your bot. Invite a new user and login as that user
and navigate to the Profile page. First click on API Access to generate
a new API token; you’ll need to allow all the scopes that start with
"View" and "Send". Then, navigate to XMPP/Jabber info to lookup the rest
of the environment variables you’ll need.

Now it’s time to run ``docker-compose``. From the same directory
containing the ``docker-compose.yml`` and your edited
``docker-compose.override.yml``, run the following with the API token
you generated and the XMPP configuration you looked up.

.. note:: Your ``HIPCHAT_JABBER_PASSWORD`` is just your normal HipChat
          password for that account and your ``HIPCHAT_NICKNAME`` is the unique mention name for your user without the ``@`` prefix.


.. code-block:: bash

    export HIPCHAT_API_TOKEN=0bnYC5notarealtokenP8TxMfzPhtheRl2DkoNZ6
    export HIPCHAT_JABBER_ID=479543_0000000@chat.hipchat.com
    export HIPCHAT_JABBER_PASSWORD=sekr3t
    export HIPCHAT_NICKNAME=cog
    docker-compose up

Now you can move on to the section titled
`Creating a User and Running a Command`_, as the rest isn’t
Slack specific. The only caveat is that when creating a chat-handle,
you’ll need to specify ``--chat-provider=hipchat`` instead.

.. |Max| image:: ../images/max.png


.. _installation_guide_create_user:

Creating a User and Running a Command
-------------------------------------

It’s pretty obvious that you’d be able to talk to a chat bot via chat.
But, we’ve included another way to interact with Cog without using chat.
It’s a command-line tool named ``cogctl`` which is available on the Cog
container we just started with Docker Compose. To start using it run the
following command to start a new shell on the Cog container. You’ll need
to run all future ``cogctl`` commands from this shell.

.. code-block:: bash

    docker-compose exec cog bash

Great now let’s create you a new Cog user and associate that user with
your Slack handle. Your Cog user can be anything you want and is not
specific to your Slack account, which will come in handy when
communicating with Cog outside of chat.

.. code-block:: bash

    cogctl user create patrick \
      --first-name="Patrick" \
      --last-name="Van Stee" \
      --email="patrick@operable.io" \
      --password="supersecret"

    cogctl chat-handle create patrick slack vanstee

Great, now Cog should know who you are when running a command in chat.
You can try it out by running that ``help`` command again.

Great, you can run a command. But, not all commands can be run without
permissions. For instance, you’ll notice if you type
``@cog bundle list`` into chat, Cog responds with an error stating
``Sorry, you aren't allowed to execute
'operable:bundle list'``. That’s because bundle commands require
permissions, like many other important commands.

Using groups, roles, and permissions you can heavily customize who has
permissions to do what. But, for now, since we just want to explore what
Cog has to offer, add yourself to the ``cog-admin`` group, which will
give you permission to run all the pre-installed commands.

.. code-block:: bash

    cogctl group add cog-admin patrick

You should now be able to list bundles or even install them as you’ll
see in the next section.

.. _installation_guide_bundle:

Installing and Configuring a Bundle
-----------------------------------

So, you’ve already run your first command, but you might have noticed
that Cog only comes with a handful of pre-installed commands. How do we
go about installing more commands? By installing bundles, of course.

Bundles are groups of commands, permissions, and templates that can be
installed either by referencing a config file directly or by name in the
`bundle registry <https://bundles.operable.io>`__. So, let’s install one
by running a chat command.

.. code-block:: chat

    max 10:52PM @cog bundle install ec2

And that’s it. Now, if you run the ``help`` command, you’ll notice the
new ``ec2`` bundle is listed under "Disabled Bundles". Before we can run
a command, we need to enable it, tell our Relay that it can run commands
from this bundle, and configure it with credentials.

.. code-block:: chat

    max 10:55PM @cog bundle enable ec2
    max 10:55PM @cog relay-group member assign default ec2

Now the the ec2 bundle is enabled, but we still haven’t configured it
yet. Let’s set our api token with ``cogctl``.

.. code-block:: bash

    echo 'AWS_ACCESS_KEY_ID: "AKIBU34ZNOTAREALTOKENQ"' >> config.yaml
    echo 'AWS_SECRET_ACCESS_KEY: "YQ7h84BCvE4fJnotarealtokenO8zpAIbulblb6MCHkO"' >> config.yaml
    echo 'AWS_REGION: "us-east-1"' >> config.yaml
    cogctl bundle config create ec2 config.yaml

Now there’s just one last step; making sure we have permission to run
ec2 commands by adding some privileges to the ``cog-admin`` group.

.. code-block:: chat

  @cog permission grant ec2:read cog-admin
  @cog permission grant ec2:write cog-admin
  @cog permission grant ec2:admin cog-admin

Now try it out!

.. code-block:: chat

  @cog ec2:instance list
