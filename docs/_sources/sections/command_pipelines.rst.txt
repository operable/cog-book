Command pipelines
=================

Piping the output of one command into another is a staple of the Unix
command-line experience. It enables the "Unix Philosophy" of having
simple tools that do one thing and do it well, allowing users to
construct processing pipelines to do complex tasks using simple building
blocks.

What if you could do the same thing with your chat ops tools? With Cog,
you can.

Pipelines
---------

.. code:: sh

    !ec2:list | filter --field="zone" --matches="us-east-1a" | ec2:terminate $instance-id

Pipelines allow you to pass the output of one command into a subsequent
invocation, allowing you to achieve things like the above invocation. In
English: "List all my EC2 nodes, keep only those in the ``us-east-1a``
availability zone, and terminate just those instances". It’s much easier
to compose simple commands in this way, versus writing one command that
incorporates listing, filtering, and termination into one operation.

Command Execution
~~~~~~~~~~~~~~~~~

Commands return results formatted as maps of key-value pairs. Commands
may return one or multiple results. In either case results are always
returned contained in a list. Commands operate on each result from
previous commands individually and independently of any others (that is,
the command is run *multiple times*, one for each result).

Some examples will be illustrative. In each case, we’ll pipe the output
through the ``operable:raw`` command, which exposes the raw structure of
these response maps.

To show all the rules currently in effect for the
``operable:permissions`` command, I can execute the following command:

.. code:: sh

    operable:rule list --command=operable:permissions | raw

The response is actually a list of maps, one for each rule. Here, we can
see there are three:

.. code:: json

    [
      {
        "rule": "when command is operable:permissions with option[user] == /.*/ must have operable:manage_users",
        "id": "f96ec769-dc85-4c95-a7f0-d87c330510bf",
        "command": "operable:permissions"
      },
      {
        "rule": "when command is operable:permissions with option[role] == /.*/ must have operable:manage_roles",
        "id": "32938757-6e75-48d4-ad6f-6a4012ff0b15",
        "command": "operable:permissions"
      },
      {
        "rule": "when command is operable:permissions with option[group] == /.*/ must have operable:manage_groups",
        "id": "9c75a1e5-8591-4577-97a9-3bfeeaf4317c",
        "command": "operable:permissions"
      }
    ]

If we were to add echo to our pipeline, we would expect it to be
executed 3 times (once for each input).

.. code:: sh

    operable:rule list --command=operable:permissions | echo $rule | raw

This is exactly what we get:

.. code:: json

    [
      {
        "body": [
          "when command is operable:permissions with option[user] == /.*/ must have operable:manage_users"
        ]
      },
      {
        "body": [
          "when command is operable:permissions with option[role] == /.*/ must have operable:manage_roles"
        ]
      },
      {
        "body": [
          "when command is operable:permissions with option[group] == /.*/ must have operable:manage_groups"
        ]
      }
    ]

.. note:: The output of an ``echo`` invocation is a map, even though we
    are echoing a simple string: the rule text. The pipeline execution logic
    ensures that such data is wrapped in a map to ensure a consistent
    interface for all commands.

Collecting results
^^^^^^^^^^^^^^^^^^

Usually it’s best to operate on input from previous commands one result
at a time. This helps to keep commands simple and to the point. But
there are occasions when you may want to operate on all of the results
at once. Let’s continue our previous example to see why.

First, let’s just echo the command a rule applies to:

.. code:: sh

    operable:rule list --command=operable:permissions | echo $command | raw

Since all rules are from the same command, we simply get the command
name repeated for as many times as there are rules:

.. code:: json

    [
      {
        "body": [
          "operable:permissions"
        ]
      },
      {
        "body": [
          "operable:permissions"
        ]
      },
      {
        "body": [
          "operable:permissions"
        ]
      }
    ]

Now, we add ``operable:unique`` to the pipeline.

.. code:: sh

    operable:rule list --command=operable:permissions | echo $command | unique | raw

.. code:: json

    {
      "body": [
        "operable:permissions"
      ]
    }

As expected, our collection of three results is reduced down to a single
result. Unlike many commands ``operable:unique`` requires access to the
entire list of inputs in order to do it’s job. Cog provides a few
additional tools to make this possible.

There are two env vars that are of note: ``COG_INVOCATION_ID`` and
``COG_INVOCATION_STEP``.

-  ``COG_INVOCATION_ID`` contains the id of the current invocation. The
   invocation id will be the same for each execution of the command on a
   particular set of inputs. When the same command is called multiple
   times in the same pipeline this id will be different for each set of
   inputs. For example:

   .. code:: sh

       seed '[{"foo": "bar"},{"foo":"baz"}]' | echo $foo

   In this case echo will execute twice, once for each result from seed.
   For both executions ``COG_INVOCATION_ID`` will be the same.

-  ``COG_INVOCATION_STEP`` specifies where we are in the current
   invocation. It can contain one of three values: ``FIRST``, ``LAST``
   or the environment variable will not exist. ``FIRST`` for the first
   execution, ``LAST`` for the last execution. Another example might be
   useful:

   .. code:: sh

       seed '[{"foo":"bar",{"foo":"baz"},{"foo":"qux"}]' | echo $foo

   Here echo will be executed three times. The first step will be
   ``FIRST``, the second will not get that environment variable, and the
   last, ``LAST``. In the case that there is only a single item in the
   input list, meaning the stage is technically the first and last step,
   the step will be ``LAST``.

Given this you can collect state using the memory service, see
:doc:`services`, and process the results as a whole once you have
received everything.

Variable Substitution
~~~~~~~~~~~~~~~~~~~~~

During command execution, we select which fields of an incoming result
map are available to the command by using variable substitution to bind
values from a result to either an option or argument of the command.
This technique was used without discussion earlier, but here we take a
closer look.

To illustrate, we’ll use the ``operable:seed`` command, which can be
used to create arbitrary result maps to feed into a pipeline. Simply
pass ``seed`` a valid JSON string, and the resulting data structure will
be passed on to downstream commands.

.. code:: sh

    seed '{"thing":"stuff"}'

.. code:: json

    {
      "thing": "stuff"
    }

Using this simple seed data, we can start to experiment with variable
binding. Let’s use ``echo`` to return the value of the ``thing`` key:

.. code:: sh

    seed '{"thing":"stuff"}' | echo $thing

.. code:: sh

    stuff

Cog has taken the *value* found at the ``thing`` key in the result map
and binds it to argument 0 of the ``echo`` command. The result is the
same as if you typed ``echo stuff`` directly.

Cog can bind variables in several positions. We have already seen
binding arguments. We can also bind option values:

.. code:: sh

    seed '{"command":"operable:permissions"}' | rule list --command=$command | raw

.. code:: json

    [
      {
        "rule": "when command is operable:permissions with option[user] == /.*/ must have operable:manage_users",
        "id": "b0877b77-5c56-4514-bf33-3a1f5d5d8ae8",
        "command": "operable:permissions"
      },
      {
        "rule": "when command is operable:permissions with option[role] == /.*/ must have operable:manage_roles",
        "id": "7da40026-aaed-41fb-9e5e-f0148e48444c",
        "command": "operable:permissions"
      },
      {
        "rule": "when command is operable:permissions with option[group] == /.*/ must have operable:manage_groups",
        "id": "da83eb97-8d44-4af0-b8a7-bc7abde63622",
        "command": "operable:permissions"
      }
    ]

Option names themselves can also be bound:

.. code:: sh

    seed '{"flag":"words"}' | wc --$flag "hello world"

.. code:: json

    {
      "words": 2
    }

Note that commands only have access to the results emitted by the
command immediately preceeding them in the pipeline. This command
succeeds:

.. code:: sh

    seed '{"flag":"words"}' | wc --$flag "hello world" | echo $words

.. code:: sh

    2

But this command fails because ``wc`` does not produce a result map with
a ``flag`` key:

.. code:: sh

    seed '{"flag":"words"}' | wc --$flag "hello world" | echo $flag

.. code:: sh

    I cannot find the variable '$flag'.

You can bind multiple values in an invocation, too:

.. code:: sh

    seed '{"flag":"words","input":"hello world"}' | wc --$flag $input

.. code:: json

    {
      "words": 2
    }
