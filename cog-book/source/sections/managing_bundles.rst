Managing Bundles
================

This document details the commands used to manage bundles.

All command bundles (with the exception of the embedded ``operable``
bundle) run under one or more
`Relay <https://github.com/operable/go-relay>`__ processes, which can be
on the same machine as the Cog bot or on different machines.

To learn more about :doc:`bundles <commands_and_bundles>` or
:doc:`relays <installing_and_managing_relays>` check out the corresponding
docs.

Prerequisites
-------------

For simplicity we will be using
`cogctl <https://github.com/operable/cogctl>`__ to demonstrate bundle
management. Bundle management mostly involves use of the *bundles*
subcommand. However, you aren’t explicitly required to use ``cogctl`` to
manage bundles, you can just make calls to the api directly if you like,
but it does make things a bit easier.

So given that, I’m going to assume you have a working installation of
both Cog, Relay and ``cogctl``.

Installing bundles
------------------

Bundles are installed by uploading bundle configs to Cog. Cog then
registers the bundle. Registration includes the creation of the
permissions declared by the bundle, as well as any default rules
specified in the bundle’s metadata.

.. note::

  After installation your command will be available but it may not be
  executable by anyone yet. Before anyone can execute the new command,
  make sure their permissions are set properly. Check out
  :doc:`permissions_and_rules` to learn more.

Bundles are installed via the ``bundle install`` sub-command in cogctl.

.. code:: bash

    $ cogctl bundle install --help
    Usage: cogctl bundle install [OPTIONS] BUNDLE_OR_PATH [VERSION]

      Install a bundle.

      Bundles may be installed from either a file (i.e., the `config.yaml` file
      of a bundle), or from Operable's Warehouse bundle registry
      (https://warehouse.operable.io).

      When installing from a file, you may either give the path to the file, as
      in:

          cogctl bundle install /path/to/my/bundle/config.yaml

      or you may give the path as `-`, in which case standard input is used:

          cat config.yaml | cogctl bundle install -

      When installing from the bundle registry, you should instead provide the
      name of the bundle, as well as an optional version to install. No version
      means the latest will be installed.

          cogctl bundle install cfn

          cogctl bundle install cfn 0.5.13

    Options:
      -e, --enable               Automatically enable a bundle after installing?
                                 [default: False]
      -f, --force                Install even if a bundle with the same version is
                                 already installed. Applies only to bundles
                                 installed from a file, and not from the Warehouse
                                 bundle registry. Use this to shorten iteration
                                 cycles in bundle development.  [default: False]
      -r, --relay-group TEXT     Relay group to assign the bundle to. Can be
                                 specified multiple times.
      -t, --templates DIRECTORY  Path to templates directory. Template bodies will
                                 be inserted into the bundle configuration prior
                                 to uploading. This makes it easier to manage
                                 complex templates.
      --help                     Show this message and exit.

The config file
---------------

The only required argument for ``cogctl bundle install`` is the path to
the bundle config file.

All bundles have a config file. The file is formatted in yaml and
contains information for installing and executing commands in your
bundle. To learn more about config files read up on
:doc:`bundle_configs`. We won’t talk in detail about bundle configs
in this doc, but minimally the file must contain:

-  **name** - The name of your bundle

-  **version** - The version of your bundle in semver format.

.. note::
    Version must be a string. If you drop the patch number from the
    version, yaml will interpret it as a number and the config will fail
    validation. So if you want to just use major and minor numbers, wrap
    the version in quotes. ex: "0.1"

-  **cog\_bundle\_version** - The version of the config file format
   (currently we support version 3 and 4)

-  **commands** - A hash of commands to be included with the bundle

A minimal bundle config might look something like this:

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

The command to install the bundle would be
``cogctl bundle install /path/to/my_bundle.yaml``.

.. note::
    A bundle is disabled when it is first installed. You must enable it
    before use.

Templates
---------

The templates flag points to a directory containing any templates for
your bundle.

Templates are used by Cog to format command output. They are singular to
a specific command/adapter combo. So for example; if we wanted to
support both HipChat and Slack for our date command, we would need to
supply two templates.

When added to the config file the templates section might look something
like this:

.. code:: YAML

    ---
    ...
    templates:
      date:
        body: |
          ~each var=$results~
          `~$item.date~`
          ~end~
    ...

This works great for simple templates, but can get confusing when things
start to get more complicated. To remedy that cogctl provides some
helpers.

If you store your templates in a directory, you'll need to pass the
``--templates`` option; ``cogctl`` does not infer this by default. The
directory should contain one directory per adapter and each adapter
directory should contain a mustache file for each command. So for our
date command we would have something like this:

.. code:: Bash

    $ tree templates
    templates
    └── date.greenbar

Given a structure like this ``cogctl`` will automatically append all of
the templates in the directory to your bundle config before uploading.

Enabling and Disabling Bundle Versions
--------------------------------------

When a new version of a bundle is installed it is disabled by default.
Only one version can be enabled at a time and a version must be
explicitly enabled before Cog will route anything to it.

Enabling and disabling bundle versions is easy. Let’s say you already
have version 1.0.0 of “my-bundle” installed:

.. code:: Bash

    $ cogctl bundle versions my-bundle
    BUNDLE     VERSION  STATUS
    my-bundle  1.0.0    Enabled

You can install version 2.0.0 straightforwardly:

.. code:: Bash

    $ cogctl bundle install /path/to/my-bundle/v2/config.yaml
    $ cogctl bundle versions my-bundle
    BUNDLE     VERSION  STATUS
    my-bundle  1.0.0    Enabled
    my-bundle  2.0.0    Disabled

As always, a newly-installed bundle is disabled by default. At this
point, invoking any commands from the “my-bundle” bundle will still
execute from version 1.0.0.

Switching to the new version is as simple as:

.. code:: Bash

    $ cogctl bundle enable my-bundle 2.0.0
    $ cogctl bundle versions my-bundle
    BUNDLE     VERSION  STATUS
    my-bundle  1.0.0    Disabled
    my-bundle  2.0.0    Enabled

Now that version 2.0.0 is enabled, the update will percolate to any
Relays that “my-bundle” has been assigned to. From that point, any
“my-bundle” command invocations will execute from version 2.0.0, using
whatever access rules have been defined in that version.

And if you decide you don’t like version 2.0.0 for any reason, you can
always drop back to 1.0.0:

.. code:: Bash

    $ cogctl bundle enable my-bundle 1.0.0
    $ cogctl bundle versions my-bundle
    BUNDLE     VERSION  STATUS
    my-bundle  1.0.0    Enabled
    my-bundle  2.0.0    Disabled

You can also enable and disable bundles through chat commands:

.. code:: Cog

    User:
    !operable:bundle disable my_bundle

    Cog:
    Bundle "my_bundle" version "0.1.0" has been disabled.

    User:
    !operable:bundle enable my_bundle 0.1.0

    Cog:
    Bundle "my_bundle" version "0.1.0" has been enabled.

    **Note**

    You cannot disable the embedded ``operable`` bundle.

Relay Groups
~~~~~~~~~~~~

Cog manages all of your command bundles and relays. Bundles are
associated to relays via relay-groups. When a bundle is installed and
assigned to a relay-group, Cog pushes the command config to the
appropriate relay or relays. When a command is invoked, Cog uses the
relay-group to select which relay is capable of running which command.

Relay groups are managed through ``cogctl`` with the ``relay-group``
sub-command. For more information read up on
:doc:`installing_and_managing_relays`.

Optionally during bundle creation you can pass the ``--relay-group`` option multiple times.

Bundles are assigned to relays via relay groups using ``cogctl``.

.. code:: Bash

    $ cogctl relay-group assign my_relay_group my_bundle

.. note::

    The default refresh interval for a relay is 15 minutes (set in the
    relay configuration file - ``relay.conf``). Be sure to wait for the
    specified amount time in order to see the bundle appear on the
    relays in the assigned relay group.

Uninstalling Bundles and Bundle Versions
----------------------------------------

You may uninstall a specific version of a bundle or all versions of a
bundle. Uninstalling a specific version will remove rules and
permissions only associated with that version. Uninstalling all bundle
versions involves *complete* removal of all authorization rules
governing its commands as well as deletion of all the bundle’s
permissions. Any custom rules you may have written concerning the
commands in the bundle will also be deleted. In this regard, bundle
uninstallation is not reversible. You can re-install to get back the
bundle permissions and default rules, but your custom ones will be gone
forever. If you only wish to disable a bundle, see
`Enabling and Disabling Bundle Versions`_ above instead.

Before a bundle can be uninstalled it must first be disabled. To
uninstall a bundle just use ``cogctl``.

.. warning::

    Since uninstalling all versions of a bundle can be quite
    destructive, you must pass the ``--all`` flag to ``cogctl``.
    Otherwise nothing will happen.

.. code:: Bash

    $ cogctl bundle uninstall --help
    Usage: cogctl bundle uninstall [OPTIONS] NAME [VERSION]

      Uninstall bundles.

    Options:
      -c, --clean         Uninstall all disabled bundle versions
      -x, --incompatible  Uninstall all incompatible versions of the bundle
      -a, --all           Uninstall all versions of the bundle
      --help              Show this message and exit.

    $ cogctl bundle uninstall my_bundle 0.1.0
    Uninstalled my_bundle 0.1.0

    $ cogctl bundle uninstall my_bundle
    Usage: cogctl bundle uninstall [OPTIONS] NAME [VERSION]

    Error: Invalid value for "version": Can't uninstall without specifying a version, or --incompatible, --all, --clean

    $ cogctl bundle uninstall date 0.1.0
    Usage: cogctl bundle uninstall [OPTIONS] NAME [VERSION]

    Error: Invalid value for "version": Cannot uninstall enabled version. Please disable the bundle first

    $ cogctl bundle uninstall date --all
    Usage: cogctl bundle uninstall [OPTIONS] NAME [VERSION]

    Error: Invalid value for "bundle": date 0.1.0 is currently enabled. Please disable the bundle first.

    $ cogctl bundle disable date
    Disabled date

    $ cogctl bundle uninstall date --all
    Uninstalled date 0.0.1
    Uninstalled date 0.0.1
    Uninstalled date 0.1.0
