Command Output Tags
===================

Commands can print tags to stdout to communicate with Cog. To use one,
print it to STDOUT at the beginning of a newline before returning your
actual response. If you’re not returning JSON output (by using the JSON
tag), you may intersperse tags in along with lines of output if
necessary.

Examples
--------

Output from a command that includes a debug statement, template
selection, and JSON response. The debug statement will be printed in the
logs of the Relay it ran on, while the JSON output will be rendered in
template specified and sent to chat as shown below.

Output from command:

.. code-block:: console

    COGCMD_DEBUG: Requst took 53ms to complete
    COG_TEMPLATE: instances
    JSON
    [
      {
        "instance_id": "i-1984f3",
        "instance_type: "t2.micro"
      },
      {
        "instance_id": "i-2a7b11",
        "instance_type: "t2.small"
      }
    ]

Relay logs:

.. code-block:: console

    DEBU[2016-12-06T11:10:14-05:00] (P: 2b113f571dc14419870cffe5d5064e69 C: ec2:instance-list) Request took 53ms to complete

JSON response passed to the instances template:

.. code-block:: json

    [
      {
        "instance_id": "i-1984f3",
        "instance_type": "t2.micro"
      },
      {
        "instance_id": "i-2a7b11",
        "instance_type": "t2.small"
      }
    ]

Output from a command in freeform text which also includes two info
statements and also uses a template. The info statement will be printed
in the logs of the Relay it ran on, while the text output will be
rendered in the template specified and sent to chat. Even though tags
were interspersed in the text output, each line that does not start with
a tag will be accumulated in an array in the order they were printed.
That array will then be included in a JSON object as the value of the
``body`` attribute. This JSON can then be used to render a template if
provided.

Output from command:

.. code-block:: console

    INSTANCE_ID  INSTANCE_TYPE
    COGCMD_INFO: 2 instances returned
    i-1984f3     t2.micro
    i-2a7b11     t2.small
    COG_TEMPLATE: monospace

Relay logs:

.. code-block:: console

    INFO[2016-12-06T11:10:14-05:00] (P: 2b113f571dc14419870cffe5d5064e69 C: ec2:instance-list) 2 instances returned

JSON response passed to the monospace template:

.. code-block:: json

    [
      {
        "body": [
          "INSTANCE_ID  INSTANCE_TYPE",
          "i-1984f3     t2.micro",
          "i-2a7b11     t2.small"
        ]
      }
    ]

Tags
----

``COGCMD_ACTION``
    Currently only used to abort a command by printing
    ``COGCMD_ACTION: abort``. Aborting a command is different from
    returning a non-zero exit code. When a command is aborted, the
    pipeline will stop executing and anything printed to stdout will be
    returned verbatim as a response in chat. The error template will not
    be rendered. This is mostly useful for providing concise error
    messages, such as validation errors, while non-zero exit codes are
    better suited for unexpected error conditions.

``COG_TEMPLATE``
    Renders the response with the template provided. For example, if
    your bundle includes a template named "instance-list" you would
    output ``COG_TEMPLATE:
    instance-list`` before outputting your response. If not used with
    JSON output expect the raw text output from your command to be
    available in the ``$body`` attribute of the first item of
    ``$results`` in the template.

``JSON``
    Parses the following response as JSON. Must be printed on a new
    line, by itself, directly before your command’s output. If not
    provided all non-tag output is assumed to be raw text. Anything
    output after this tag will be parsed as JSON, so you must not
    include any other tags after this one.

``COGCMD_DEBUG``
    Prints a log message to Relay with the log level set to DEBUG.

``COGCMD_INFO``
    Prints a log message to Relay with the log level set to INFO.

``COGCMD_WARN``
    Prints a log message to Relay with the log level set to WARN.

``COGCMD_ERR``; \ ``COGCMD_ERROR``
    Prints a log message to Relay with the log level set to ERROR.
