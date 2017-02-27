Bundle Configs
==============

Cog executes commands to accomplish different tasks. Commands are
organized into bundles. Bundles not only provide a way to organize
similar commands, they also keep everything, like permissions and rules,
namespaced. Every bundle includes a bundle config. Bundle configs are
written in YAML and provide all of the information necessary to install
and execute the commands included in the bundle.

Cog provides two types of bundles, simple and standard. Simple bundles
point to an executable already installed on the machine running the
relay you want to execute the command on. Simple bundles are great for
simple common commands. Standard bundles point to a repository on Docker
hub that contains the execution code for your bundle. To learn more
about packaging and building bundles for Cog, check out :doc:`writing_a_command_bundle`.

.. _simple_bundle_target:

Simple bundle configs
---------------------

To start, lets discuss configs for simple bundles. Simple bundle configs
look like this:

**simple_config.yaml.**

.. code:: YAML

    ---
    cog_bundle_version: 4

    name: my_bundle
    description: "Does bundle things"
    version: "0.1"
    commands:
      date:
        executable: "/usr/local/bin/mydate.exs"
        description: "Displays the current date and time"
        rules:
          - "allow"
    templates:
      date:
        slack: "`{{date}}`"

``name``, ``description``, ``version``, ``cog_bundle_version`` and
``commands`` are all required fields. Most of these are pretty self
explanatory but let’s go over them anyway.

-  ``name`` is simply the name of your bundle. All commands will be
   installed within a namespace defined by this field. So command names
   that collide with command names in other bundles will be invoked by
   using the fully qualified name. In this case the date command’s fully
   qualified name would be ``my_bundle:date``.

-  ``description`` is a short, one-line description for your bundle.
   This will be printed along with a list of all installed bundles when
   a user runs the help command.

-  ``version`` is the semver version number of your bundle. Currently
   Cog provides no internal mechanism for dealing with versions. If you
   want to install a new version of bundle then you first need to
   uninstall the old one. We require version because at some point we
   will provide a mechanism to upgrade bundles.

-  ``cog_bundle_version`` is the version of Cog’s bundle system that
   your bundle was built for. The current bundle version is ``4``, which
   is used through out the rest of this document.

-  ``commands`` are a hash of commands keyed by the command name. Here
   the command name is "date". For simple bundles you are only required
   to provide the ``executable`` and the ``rules`` fields. We’ll detail
   more about the ``commands`` section a little later.

In addition to the required fields there is also one optional in this
example, ``templates``. ``templates`` are a hash of templates keyed my
name. Template names should correspond to command names. In this case
the template is named "date" just like the command "date". Templates
vary from adapter to adapter so under the name of the template we key
the template strings by adapter. Currently we only support two adapters
for the purpose of templates; "slack" and "hipchat".

.. note:: cogctl, Cog's command line tool, provides some useful functionality
    for templates. You can just save templates as individual files and
    cogctl will build out the templates section for you before uploading
    the config.

Commands
--------

Commands are probably the most complex component of the bundle config so
I thought I would give it it’s own section.

As an example let’s look at an excerpt from the mist config.

**mist_config.yaml (excerpt).**

.. code:: YAML

    ...

    commands:
      ec2-find:
        executable: /usr/local/bin/ec2_find
        description: Finds an ec2 instance
        options:
          region:
            type: string
            required: true
          tags:
            type: string
            required: false
          ami:
            type: string
            required: false
          state:
            type: string
            required: false
          return:
            type: string
            required: false
            description: Valid values are id, pubdns, privdns, state, keyname, ami, kernel, arch, vpc, pubip, privip, az, tags
        rules:
          - must have mist:view
    ...

Here you will notice the command name "ec2-find" and nested under it
several fields. Let’s talk about them one at a time.

-  ``executable`` is probably the easiest but is arguably the most
   important field. It’s also the only required field in a command hash.
   ``executable`` simple points to the command script or binary that is
   to be run.

-  ``description`` is a short, one-line description for the command.
   This is the info that will appear along with a list of commands when
   a user runs the help command for a specific bundle.

-  ``options`` is a hash of arguments that the command accepts. By
   default Cog you can pass options to a command using the option name,
   ``--region`` as an example here. Options have a type, currently we
   support: int, float, bool, string, incr and list. They also have an
   optional ``short_flag`` and a ``description``.

-  ``rules`` is required and is a list of strings that define what
   permissions are required to run the command. Check out :doc:`permissions_and_rules` to learn more
   about what rules look like. A couple things to note about rules. When
   specifying rules in configs you can drop the "when command is …"
   portion like we did in the previous mist config. Cog has enough
   context to fill that bit in for you. There is also a special rule
   that opens the command up for execution by anyone, "when command is
   bundle:command allow". So when combined with the previous note you
   only need to specify the "allow" bit in configs.

Other fields
------------

To get a simple command up and running the simple config is pretty much
all that you need. But for more advanced features there are a number of
additional fields that you might want to consider.

Permissions
~~~~~~~~~~~

All commands require permissions to run. Permissions are included in the
bundle config as a list of strings at the top level. Here is another
excerpt of the mist config as an example.

**mist_config.yaml (excerpt).**

.. code:: YAML

    ---
    cog_bundle_version: 4

    name: mist
    description: Manage EC2 instances and related services
    version: 0.4.0
    permissions:
    - mist:view
    - mist:change-state
    - mist:destroy
    - mist:create
    - mist:manage-tags
    - mist:change-acl

    ...

.. _standard_bundle_target:

Standard bundle configs
-----------------------

For the most part standard bundle configs follow the same rules as
simple bundle configs. Really the only difference is the addition of the
``docker`` field. Standard bundles are deployed from docker hub as
docker images. The ``docker`` field just tells Cog where to go to get
the image.

Once again as an example, here is an excerpt from the mist config.

**mist_config.yaml (excerpt).**

.. code:: YAML

    ...

    docker:
      image: cogcmd/mist
      tag: "0.4"
    ...

It’s fairly self explanatory. There are only two fields, ``image`` and
``tag``. ``image`` refers to the image on docker hub and ``tag`` just
points to a specific tag. If you don’t pass ``tag`` Cog will grab the
most recent version of the image.

Documentation fields
~~~~~~~~~~~~~~~~~~~~

There are a number of fields dedicated to rendering manpage-style
documentation rendered by the ``help`` command both for the bundle and
the command.

Bundle
^^^^^^

-  ``long_description`` is a separate section for a longer form
   description, which can include things like what configuration is
   required, how commands should be used, and more details about the
   underlying implementation.

-  ``author`` is where the bundle author can leave their name and email
   address if a user needs their contact information.

-  ``homepage`` is a URL for the bundle, typically a github repo.

-  ``config`` is used to document your bundle configuration settings. It
   contains two sections, notes and env.

   -  ``notes`` is used to provide any additional configuration
      information that might be useful to users.

   -  ``env`` is a list of objects containing two keys; ``var``, for the
      name of your environment variable and ``description``, for an
      optional description.

**aws_cfn_config.yaml (excerpt).**

.. code:: YAML

    ...
    config:
      notes:
        The cfn bundle makes use of CloudFormation stack templates and stack policies that are defined in JSON documents and stored in pre-defined S3 locations. These locations are defined with the 'CFN_TEMPLATE_URL' and 'CFN_POLICY_URL' configuration variables.
      env:
        - var: AWS_REGION
        - var: AWS_ACCESS_KEY_ID
        - var: AWS_SECRET_ACCESS_KEY
        - var: AWS_STS_ROLE_ARN
          description: STS role ARN that should be assumed. Defined as 'arn:aws:iam::<account_number>:role/<role_name>'.
        - var: CFN_TEMPLATE_URL
          description: S3 Location of your stack templates. Defined as 's3://<bucket>/<path>'.
        - var: CFN_POLICY_URL
          description: S3 Location of your stack policies. Defined as 's3://<bucket>/<path>'.
    ...

Command
^^^^^^^

-  ``long_description`` is a long-form description used to explain
   details of a command that don’t fit into other sections like an
   explanation of required arguments or about the structure of the
   output.

-  ``examples`` is how a user will run the command and what output they
   should expect.

-  ``notes`` is a free-form section at the bottom of the command above
   ``author`` and ``homepage``

-  ``arguments`` is a short string appended to the generated synopsis
   for describing named or required arguments or subcommands.

-  ``subcommands`` is an object where the keys are the subcommand
   arguments and the values are a short one-line description of each
   subcommand.

Conclusion
----------

And that, as they say, is that. There is no more; you pretty much know
all there is to know about what goes into a config. But for the sake of
completeness and to help you tie everything together, here is the mist
config in it’s entirety.

**mist_config.yaml.**

.. code:: YAML

    ---
    cog_bundle_version: 4

    name: mist
    description: Manage EC2 instances and related services
    version: 0.4.0
    permissions:
    - mist:view
    - mist:change-state
    - mist:destroy
    - mist:create
    - mist:manage-tags
    - mist:change-acl
    docker:
      image: cogcmd/mist
      tag: "0.4"
    commands:
      ec2-find:
        executable: /usr/local/bin/ec2_find
        options:
          region:
            type: string
            required: true
          tags:
            type: string
            required: false
          ami:
            type: string
            required: false
          state:
            type: string
            required: false
          return:
            type: string
            required: false
        rules:
          - must have mist:view
      ec2-destroy:
        executable: /usr/local/bin/ec2_destroy
        options:
          region:
            type: string
            required: true
        rules:
          - must have mist:destroy
      ec2-state:
        executable: /usr/local/bin/ec2_state
        options:
          region:
            type: string
            required: true
        rules:
          - must have mist:change-state
      vpc-list:
        executable: /usr/local/bin/ec2_vpcs
        options:
          region:
            type: string
            required: true
          subnets:
            type: bool
            required: false
        rules:
          - must have mist:view
      keypairs-list:
        executable: /usr/local/bin/ec2_keypairs
        options:
          region:
            type: string
            required: true
        rules:
          - must have mist:view
      ec2-create:
        executable: /usr/local/bin/ec2_create
        options:
          region:
            type: string
            required: true
          type:
            type: string
            required: true
          ami:
            type: string
            required: true
          keypair:
            type: string
            required: true
          az:
            type: string
            required: false
          vpc:
            type: string
            required: false
          tags:
            type: string
            required: false
          user-data:
            type: string
            required: false
          count:
            type: int
            required: false
        rules:
          - must have mist:create
      ec2-tags:
        executable: /usr/local/bin/ec2_tags
        options:
          region:
            type: string
            required: true
          tags:
            type: string
            required: true
        rules:
          - must have mist:manage-tags
      s3-buckets:
        executable: /usr/local/bin/s3_buckets
        rules:
          - must have mist:view
          - with arg[0] == 'list' must have mist:view
          - with (arg[0] == 'delete' or arg[0] == 'rm') must have mist:destroy
      s3-bucket-files:
        executable: /usr/local/bin/s3_bucket_files
        options:
          bucket:
            type: string
            required: false
          file:
            type: string
            required: false
          policy:
            type: string
            required: false
          force:
            type: bool
            required: false
        rules:
          - must have mist:view
          - with option[set-policy] == /.*/ must have mist:change-acl
