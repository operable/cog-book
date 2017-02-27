Bootstrapping Cog
=================

Since interactions with Cog require a user account, you’ll need to
*bootstrap* your system before you can do anything interesting with it.
This process will create the necessary administrator role and user
group, as well as create the first user account and place it into that
administrator group. At this point, you can interact with Cog as this
first privileged user in order to create other user accounts (to which
you can also grant administrative access), install bundles, and perform
other tasks.

There are a few ways you can bootstrap. If your Cog system is automated
in any way (using Chef, Puppet, Ansible, or some flavor of AWS or Heroku
deployment, for example), you may find it convenient to :doc:`automatically
bootstrap your new system using environment
variables <permissions_and_rules>`.

Alternatively, you can use the ``cogctl bootstrap`` command, as detailed
below.

Whichever way you choose, read further on this page, as the underlying
principles are the same.

.. code:: shell

    cogctl bootstrap http://cog.mycompany.com:4000
    Bootstrapping the server

.. note:: You can run ``cogctl bootstrap`` multiple times; if the system is
    already bootstrapped, ``cogctl`` will alert you and return a ``1``
    exit code, but the Cog system itself will remain unaffected.

If you take a look in ``~/.cogctl``, you’ll begin to see what has
happened.

.. code:: shell

    cat ~/.cogctl
    [defaults]
    profile=cog.mycompany.com

    [cog.mycompany.com]
    url=http://cog.mycompany.com:4000
    password=BgEocTFGzON$U39srRt5^fi(ZD0KxV*1
    user=admin

Here, we can see that a user named ``admin`` has been created for us on
the Cog instance running on this machine. A password has also been
generated for this user. Now, whenever we run any ``cogctl`` commands
from this machine, these credentials will be used by default to make
authenticated API calls.

Cog’s REST API is guarded by Cog’s authorization system, which means
that the admin user must have permissions to access the API somehow. As
detailed in :doc:`permissions_and_rules`, permissions must be
attached to a user somehow through a combination of roles and groups. As
you can probably guess, the bootstrapping process handles all this.
Let’s use ``cogctl`` to examine what has been done.

First, let’s just check that we actually exist :smile:

.. code:: shell

    cogctl user
    USERNAME  FULL NAME          EMAIL ADDRESS
    admin     Cog Administrator  cog@localhost

*phew!*

Now let’s examine the core permissions of the Cog system. These govern
fine-grained access to the various REST API endpoints and chat commands.

.. code:: shell

    cogctl permission
    NAME                         ID
    operable:manage_commands     a8cd921d-49a9-497a-a977-79ad50512df9
    operable:manage_groups       fa9d0311-2791-462a-9bf9-05fe29299109
    operable:manage_permissions  cf604203-f546-43cb-8677-51c698140867
    operable:manage_relays       365228d2-d082-4bfa-ac7d-ff731a92100d
    operable:manage_roles        fec52faa-5106-4982-ad0b-cbe5307c26ec
    operable:manage_triggers     4b6b01d7-0d54-4435-befd-c9bb23212404
    operable:manage_users        65de7570-7b3f-4ebd-98fd-786f9e9b5cc2

That’s a lot of permissions; Cog helps us out by creating a
``cog-admin`` role to collect them all together.

.. code:: shell

    cogctl role info cog-admin
    Name         cog-admin
    ID           15c77231-e53f-4ab9-b438-64b4a2f636d6
    Permissions  manage_commands, manage_groups, manage_permissions, manage_relays, manage_roles, manage_triggers, manage_user_pipeline, manage_users
    Groups       cog-admin

To complete the loop, we have a group that is also named ``cog-admin``
with the ``admin`` user as its sole member. This group is granted the
``cog-admin`` role.

.. code:: shell

    cogctl group info cog-admin
    ID     88f30dec-ca13-4d92-a6bd-4631acc7424b
    Name   cog-admin
    Users  admin
    Roles  cog-admin

Though the Cog admin user is named ``admin``, there’s nothing
particularly special about that name. As this tour of the bootstrapping
process has shown us, the ``admin`` user functions as an administrator,
able to perform any task in the Cog system, only because it resides in a
group that has been granted all the core permissions. *Any* user in this
group would have the same capabilities.

This also shows how to make any Cog user an administrator; simply add
them to the ``cog-admin`` group.
