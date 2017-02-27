Designing ChatOps Commands
==========================

Small Sharp Tools
-----------------

-  Commands should do one thing well. Multiple modes or actions indicate
   poor design.

-  Perform complex workflows by composing multiple commands into
   pipelines.

   -  Complex commands are inscrutable black boxes.

   -  Complex pipelines are explicit and readable.

-  Define aliases and use them to run common pipelines.

Naming
------

-  Bundle and command names should be descriptive but short as possible:
   ``cp``, ``mv``, ``tr``.

-  Short bundle names minimize the pain of manually disambiguating
   command name conflicts. ``s3:cp`` not ``aws-s3:cp``.

-  Good bundle names avoid doing too much. Prefer ``s3`` over ``aws``.

Designing Command Interfaces
----------------------------

-  A well designed command reads like prose and can be diagrammed like a
   sentence.

   -  noun verb noun → bundle command arg(s)

   -  The tree caught the kite → tree:catch kite

-  Follow existing Unix CLI conventions when possible. *Especially* when
   building a command which is similar to an existing Unix command.
   ``s3:cp src dest`` not ``s3:cp --source=src --dest=dest``.

-  Prefer arguments over options.

   -  Arguments require less typing and naturally support multiple
      values.

   -  Options require more typing and are clunky to use when multiple
      values must be given.

-  Arguments should refer to targets of the same or closely related
   types.

-  When using options set sane default values to the maximum extent
   possible. Target the most common use cases.

   -  Options should be used to indicate when the command should depart
      from default behaviors. For example, a ‘s3:ls\` command might have
      a ``--acls`` option to indicate when it should display bucket
      entries’ S3 ACLs.

-  Obey the *DWIM* (Do What I Mean) principle as much as possible. If
   you have a ``pagerduty:page`` command that takes a username and send
   a message, don’t require quotes around the message — simply
   concatenate all of the arguments after the name since you can
   reasonably infer the intent.

    **Note**

    **Bad**:
    ``pagerduty:page --user=djohnson --message="has the db restore finished?"``

    **Better**:
    ``pagerduty:page djohnson "has the db restore finished?"``

    **Best**: ``pagerduty:page djohnson has the db restore finished?``

Pipeline Friendly Output
------------------------

-  Design tools with the expectation that they’ll be combined with other
   tools and as part of scripts.

-  Avoid reusing field names to refer to different types of data
   whenever possible.

   -  Nested collections are the only exception. The collection field
      name provides enough context to avoid confusion.

-  Bias toward returning data verbosely and filtering what the user is
   presented with at the template level. This allows maximum flexibility
   to work with the returned data in ways that the author did not
   expect.

-  Templates should focus on providing the simplest possible output that
   returns the most commonly needed data.

-  Only accumulate output when you absolutely must. Prefer stateless
   commands over stateful streaming commands.
