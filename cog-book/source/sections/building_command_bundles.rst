Building Command Bundles
========================

Now that you know what a Cog bundle is, how do you build one? There are
two different types of command bundles: **simple** and **standard**.
Bundles can be written using any language of choice. Languages that have
been tested so far: Python and Ruby, but feel free to explore with
others. Bundles all have access to the Cog acceptable environment
variables.

What is a Cog acceptable environment variable?
----------------------------------------------

I’m glad that you asked. Environment variables using the prefix ``COG_``
are reserved for Cog’s use. The ``COG_`` protected environment variables
are used when executing commands. For arguments, Cog sets any arguments
passed to commands as environment variables starting with ``COG_ARGV_``.
For example, the following variables will be set as the result of a
command with 3 arguments as input ``mycommand foo bar baz``.

\`\`\` \* COG\_ARGC=3 \* COG\_ARGV\_0="foo" \* COG\_ARGV\_1="bar" \*
COG\_ARGV\_2="baz" \`\`\`

Options work in a similar manner. For options Cog sets any options
passed to commands as environment variables starting with ``COG_OPT_``.
Note with options, you must set the options in the ``config.yaml`` file
accordingly and the environment variable will use the option name when
defining the environment variable. (We’ll get to that in a moment.) So
if you have the following command, these will be the options set in the
Cog environment variable: ``mycommand --verbose --force --id=123``.

\`\`\` \* COG\_OPTS="verbose,force,id" \* COG\_OPT\_VERBOSE="true" \*
COG\_OPT\_FORCE="true" \* COG\_OPT\_ID="123" \`\`\`

There are other Cog specific variables that are available for use within
any commands. The following can be accessed from the Cog environment.

-  ``COG_BUNDLE``: A string containing the bundle name of the command
   being executed. Example: "operable".

-  ``COG_COMMAND``: A string containing the command name being executed.
   Example: "mycommand".

-  ``COG_CHAT_HANDLE``: A string containing the chat handle of the user
   attempting to execute the command. Example: "imbriaco".

-  ``COG_PIPELINE_ID``: A string containing the UUID of the pipeline
   that the command communication is transporting over. Example:
   "374643c4-3f48-4e60-8c4f-671e3a11c06b".

-  ``COG_ROOM``: The name of the chat room / channel the command
   originated from. For 1-on-1 interactions, this will be the string
   ``"direct"``.

.. _simple_bundle_target:

Simple Bundles
--------------

These are the simplest type of command bundles consisting only of a YAML
file. The YAML file has variables that refer to commands that can be
executed via an executable that is able to access Cog acceptable
environment variables. The executables are not a part of the managed
simple bundle, but are managed separately by the system administrator.
When executing simple commands, the system administrator should take
care to ensure that the executables are where the YAML file expects them
to be and that they use the Cog environment variables for accessing
arguments and options.

For **simple** bundles, the bundle file used within Cog’s Relay is the
``config.yaml`` file. That’s it. Very simple. See the bottom section for
details of the fields that are included in the file.

For example, here is an example of what a secured\_ping.yaml file would
look like. The ``secured_ping.sh`` script is placed in ``/path/to/`` so
that the script can be executed by Cog. The script also contains code
that accesses the ``COG_ARGV_0`` environment variable in order to
execute pinging to the given host. Remember the script is not a part of
the bundle, so an administrator can change the script as much as they
need without restarting any Cog process, given that they don’t change
the inputs that are expected in the command.

**secured\_ping.yaml.**

.. code:: YAML

      ---
      name: ping
      version: "0.1"
      cog_bundle_version: 3
      commands:
        secured_ping:
          executable: "/path/to/secured_ping.sh"
          documentation: ping <host> - send ICMP ECHO_REQUEST packets to network hosts
          rules:
          - "must have ping:read"

There are more `sample simple command
bundles <https://github.com/operable/sample_simple_bundle>`__ located in
a separate repository.

.. _standard_bundle_target:

Standard Bundles
----------------

**Standard** bundles are much like **simple** bundles, but instead of
just pointing to an already existing script on the relay, bundles are
packaged as Docker images. This helps to sandbox bundles and leverages
`Docker Hub <https://hub.docker.com/>`__ as a distribution system.

To create standard bundles just package all of your commands in a docker
image and push it to Docker Hub. Then add this section to you
``config.yaml``:

**config.yaml.**

.. code:: YAML

      docker:
      image: "my_bundles/secured_ping" // Docker Hub image
      tag: "0.1"
      binds: // Optional
        - /path/on/host:/path/in/container
        - /another/host/path:/another/container/path

You can mount host directories from your Relay host into your containers
by adding the optional ``binds`` key to the above ``docker`` section.
This should be a list of volume binding strings (as you would pass to
Docker’s `/containers/create API
endpoint <https://docs.docker.com/engine/reference/api/docker_remote_api_v1.24/#/create-a-container>`__
(Look for ``HostConfig -> Binds`` in the ``POST`` body. For example, if
you’re writing a command that might need access to a socket file from
the host, you can expose it in the container this way.
