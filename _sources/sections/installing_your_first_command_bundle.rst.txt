Installing Your First Command Bundle
====================================

*Might be some good info to have*

So you’ve installed Cog, you have a relay instance up and running and
``cogctl`` ready to go. Now what to do? Well, if your answer is, "I’d
like to install a bundle!" then read on, you have come to the right
place.

| **tl;dr**
| Bundle installation is pretty simple once you have everything you
  need. In short there are only three primary steps. First you create
  the bundle, next we assign the new bundle to a relay, and last we
  enable it.
|

.. note:: Note that there are some extra flags that can be passed to
    ``cogctl bundle install`` that can shortcut some of the steps here.
    Namely the ``--enable`` and ``--relay-group`` flags. Check out
    :doc:`managing_bundles` to learn more.

Creating your bundle
--------------------

In order to create a bundle you only need one thing, a bundle config.
Bundle configs are formatted in YAML and supply Cog with all the
information it needs to install and execute commands in you bundle.

.. note:: To get all the nitty gritty about bundle configs go to the
    :doc:`bundle_configs` section in the docs.

For our example we will be using the following config. It’s a simple
bundle with only one un-enforcing command. Just create a file named
``my_bundle.yaml`` and paste the contents below into it. It doesn’t
actually matter what you name the file, just make sure that it is
properly formatted YAML and that it has the correct extension, ``.yaml``
or ``.yml``.

**my_bundle.yaml.**

.. code:: YAML

    ---
    cog_bundle_version: 4

    name: my_bundle
    description: My bundle
    version: "0.1"
    commands:
       date:
         executable: /bin/date
         rules:
         - "allow"

.. warning:: If your commands specify any rules, other than the special "allow"
    rule, you will need to make sure the proper grants are in place.
    Check out :doc:`permissions_and_rules` to learn more.

Ok, so now that we have our config file ready, let’s create that bundle.

Bundles are most easily created with Cog’s command line interface,
``cogctl``. To create your bundle just type the following at the command
prompt. Adjust the ``my_bundle.yaml`` bit to point to the config file
that you created.

.. code:: bash

    $ cogctl bundle install my_bundle.yaml

And there you have it! Bundle created. Now let’s see about assigning it
to a relay.

Assigning your bundle to a relay
--------------------------------

Bundles are assigned to relays via relay groups. To learn more about
relays and relay groups check out
:doc:`installing_and_managing_relays`. For the sake of this exercise
we’ll assume that you already have a relay group created,
*my_relay_group*, and that it has at least one relay as a member.

Once again we can use ``cogctl`` to assign bundles to relay groups.

.. code:: bash

    $ cogctl relay-group assign my_relay_group my_bundle
    Relay group 'my_relay_group' has the following assigned bundles: my_bundle

Enabling your bundle
--------------------

By default any bundles added to Cog are added in the *disabled* state.
This way you don’t have to worry about accidentally exposing commands
that aren’t fully configured, or otherwise un-ready for prime time.

Enabling commands is easy though. We’ll use ``cogctl``! I betcha didn’t
see that one coming :) By default the highest installed version of a
bundle will be enabled. To enable a different version just pass the
version to enable to cogctl.

.. code:: bash

    $ cogctl bundle enable my_bundle

    $ cogctl bundle enable my_bundle 0.2.0

Profit!
-------

I know I said there were only three steps. And technically there are,
but I have a thing for the whole "last step == PROFIT!!" thing.

For real though, that’s it. You have successfully installed your first
bundle. If everything went properly you should see the new command in
Cog’s help and be able to run it.

.. code-block:: Cog

    User:
    !help

    Cog:
    I know about these commands:

     * my_bundle:date
     * operable:alias
     * operable:bundle
     * operable:echo
     * operable:filter
     * operable:greet
     * operable:group
     * operable:help
     * operable:max
     * operable:min
     * operable:permissions
     * operable:raw
     * operable:role
     * operable:rules
     * operable:seed
     * operable:sleep
     * operable:sort
     * operable:sum
     * operable:table
     * operable:thorn
     * operable:unique
     * operable:wc
     * operable:which

     Try calling `operable:help COMMAND` to find out more.

     User:
     !date

     Cog:
     Tue Mar 29 18:07:41 EDT 2016
