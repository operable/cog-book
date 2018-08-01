Services
========

Overview
--------

The majority of chat commands are not full fledged applications by
themselves. They require access to external application APIs and other
resources to function. Given there are a finite (but still large) number
of applications and a much smaller number of ways to access them it’s
not all that surprising to see unrelated chat commands sharing a common
set of requirements.

Examples of these requirements include:

-  Managing state related to chat users and/or command execution

-  "Shelling out" to aliases/pipelines/commands

-  Accessing REST APIs

Design Journey
--------------

Cog provides a suite of services — and later a user-extendible API — to
satisfy requirements like these. This document will discuss the general
design principles of Cog services and specifics on the two services
included in Cog 0.5.0: ``memory`` and ``exec``.

Four design criteria heavily influenced the design and technology
choices of what became Cog Services.

1. | Security
   | Only authorized users should be able to access services. Cog must
     aggressively identify and validate each access.

2. | Audit
   | Service use must be part of Cog’s audit log. Administrators should
     regard the log as a comprehensive journal of user <→ Cog
     interactions.

3. | Flexibility
   | The overall service API design shouldn’t impose unnecessary
     implementation limits on the types and kinds of services offered.

4. | Ease of use
   | Interacting with services should be a pleasant experience for
     command authors. Given Cog’s language agnostic design this implies
     services will be accessible from a wide variety of programming
     languages and environments.

Several candidate designs and technologies were evaluated against the
above principles.

-  | **Services Over MQTT**
   | The first idea was to leverage Cog’s internal message bus as a
     service transport exposing services directly to commands via
     Relay’s command runtime environment.

   -  Pros: Good security and auditability via tight integration w/Cog’s
      existing infrastructure; Simplified service access via Relay.

   -  Cons: Requires design and implementation of an entire RPC path and
      data encoding; Service clients would necessarily be one-off and
      custom preventing any reuse of existing libraries or protocols;
      Maintaining lots of custom client code eventually slows down our
      velocity and impacts overall flexibility; Asking users to learn
      yet another service client API negatively impacts ease of use.

   -  Status: DISCARDED

-  | **REST-enabled Services w/Relay Proxies**
   | We then considered exposing services over HTTP with a REST-style
     API. Services would be hosted on Cog, "tunneled" over MQTT, and
     published on each Relay as REST APIs served by HTTP servers bound
     to localhost.

   -  Pros: Restricting service access to processes running on Relay
      hosts reduces service’s overall attack footprint; Using HTTP
      transport and REST API design allows us to leverage existing
      libraries across a wide range of programming langauges.

   -  Cons: Two service APIs are required: MQTT and HTTP/REST; Unclear
      how to simply map a message-driven API to REST especially in an
      automated fashion; Proxying calls from Relay to Cog is non-trivial
      and likely to become more complicated over time

   -  Status: DISCARDED

-  | **REST-enabled Services w/Token-based authentication**
   | Finally, we considered a refined version of the prior idea.
     REST-style services would be hosted and published on Cog via a
     separate HTTP listener, a la pipeline triggers. Accessing services
     will require a special token unique to each pipeline instance. This
     allows Cog to connect a service call with a user which preserves
     auditability. Cog can also use the token to propagate a user’s
     identity and permissions across service calls thereby supporting a
     strong security model.

   -  Pros: Relatively straightforward to design and implement; Reuses
      existing concepts (and potentially code) from other Cog subsystems
      including ACL evaluation and pipeline triggers; Allows command
      author’s to use their preferred HTTP/REST library; Well defined
      API semantics; Clear path to user extensibility in the future

   -  Cons: Some complexity around pipeline token generation and
      invalidation; Increased attack surface compared to previous
      options

   -  Status: SELECTED

Cog Services API
----------------

Cog services will be managed by a separate Phoenix endpoint named
``Cog.PlatformServicesEndpoint``. Building the API as a separate
endpoint instead of a separate Phoenix app was chosen to avoid packaging
and reuse issues with Cog (since it was never designed to be a reusable
library) and also reduce the coding effort. An endpoint-based
implementation strikes a good balance between isolation, modularity, and
speed of development without constraining future choices.

The endpoint will contain its own HTTP router with the majority of
application logic contained in controllers and views. The root URL of
the services API will be exported to the command runtime environment
under the environment variable ``COG_SERVICES_ROOT``. It shall be a
valid URL starting with either ``http://`` or ``https://``, depending on
user configuration, followed by the host name or IP address and
listening port number. Examples: ``http://192.168.2.22:4005``,
``https://mycog.somecorp.com:4100``.

Authentication and Authorization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cog will generate a unique pipeline token upon pipeline initialization.
The token will correlate a pipeline to the calling user much like REST
API tokens correlate REST API sessions to calling users. Pipeline tokens
have a finite lifespan. Their expiration will be triggered by the
completion (regardless of status) of the owning pipeline.

The token will be exported to the command runtime environment under the
environment variable ``COG_PIPELINE_TOKEN``. All calls to the Cog
Service API *must* include the token in their ``Authorization`` HTTP
header like so: ``Authorization: pipeline <token>``. Requests without a
properly formed ``Authorization`` header or referencing an expired or
invalid pipeline token will receive ``401 Unauthorized``.

Routes
~~~~~~

The Services API provides an informational API to assist monitoring,
service discovery, and service enumeration. These endpoints are listed
below.

/v1/services/meta
~~~~~~~~~~~~~~

Returns a JSON object describing Cog version, Cog Services API version,
and basic information about each hosted service. The below JSON document
can be used as a normative reference.

**Request.**

.. code:: http

    GET /v1/services/meta HTTP/1.1
    Authorization: pipeline 123456789

**Response.**

.. code:: http

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: ...

    {"info":
      {
        "cog_version": "0.5.0",
        "cog_services_api_version": "1",
        "services": [{"name": "exec",
                      "version": "1.0"},
                     {"name": "state",
                      "version": "1.0"}]
      }
    }

Memory Service
--------------

Command invocations are essentially stateless. Cog’s pipeline execution
model instantiates a fresh command instance for each invocation,
operating system process or Docker container depending on command bundle
packaging, with no ability to refer to data from previous invocations or
store data for future invocations. This is by design as it simplifies
pipeline management and execution and encourages development of small,
composable, stateless commands.

There are times where state is simply required. Commands which need
access to all prior pipeline output are difficult if not impossible to
build without state. Unix CLI like ``sort`` and ``uniq`` are good
examples. The memory service is intended to address precisely these
kinds of requirements.

Data Model
~~~~~~~~~~

The memory service’s API resembles a hash map with two kinds of put
(accumulating or replacing) and delete.

.. note:: The visibility and lifetime of data stored in the memory service is
    tied to the lifetime of the enclosing pipeline. This means commands
    executing under separate pipelines can see different values or even
    no value at all for the same key. Once a pipeline has exited the
    memory service will flush all data stored by command executing in
    that pipeline.

Returns the current value of ``{key}``. Returns 404 for missing keys.

**Request.**

.. code:: HTTP

    GET /v1/services/memory/1.0/foo HTTP/1.1
    Authorization: pipeline 123456789

**Response.**

.. code:: HTTP

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: ...

    {"key": "foo",
     "value": [1,2,3,4,5]}

Stores or updates the value corresponding to ``{key}``. If ``{key}``
already exists then an update will be performed based on the value of
the ``op`` field.

Accumulate (Default)
^^^^^^^^^^^^^^^^^^^^

**Request.**

.. code:: HTTP

    POST /v1/services/memory/1.0/foo HTTP/1.1
    Authorization: pipeline 123456789
    Content-Type: application/json

    {
      "op": "accum",
      "value": 2
    }

**Response.**

.. code:: HTTP

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: ...

    {
      "value": [1,2]
    }

**Request.**

.. code:: HTTP

    POST /v1/services/memory/1.0/foo HTTP/1.1
    Authorization: pipeline 123456789
    Content-Type: application/json

    {
      "op": "accum",
      "value": [2, 3]
    }

**Response.**

.. code:: HTTP

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: ...

    {
      "value": [1,[2,3]]
    }

**Request.**

.. code:: HTTP

    POST /v1/services/memory/1.0/foo HTTP/1.1
    Authorization: pipeline 123456789
    Content-Type: application/json

    {
      "op": "accum",
      "value": [2, 3]
    }

**Response.**

.. code:: HTTP

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: ...

    {
      "value": [{"hello": "world"}, [2, 3]]
    }

Replace
^^^^^^^

**Request.**

.. code:: HTTP

    POST /v1/services/memory/1.0/foo HTTP/1.1
    Authorization: pipeline 123456789
    Content-Type: application/json

    {
      "op": "replace",
      "value": 2
    }

**Response.**

.. code:: HTTP

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: ...

    {
      "value": 2
    }

**Request.**

.. code:: HTTP

    DELETE /v1/services/memory/1.0/foo HTTP/1.1
    Authorization: pipeline 123456789

**Response.**

.. code:: HTTP

    HTTP/1.1 204 OK

Chat Service
------------

The chat service allows you to send messages back to a channel or user
during command execution. This can be either the originating channel/user
using COG_ROOM/COG_CHAT_HANDLE environment variables, or to a specific
channel/user every time.

POST data should be in json format, usernames should be preceded with `@`
and room names preceded with `#`.

**Request.**

.. code:: http

    POST /v1/chat/1.0.0/send_message HTTP/1.1
    Authorization: pipeline 123456789
    Content-Type: application/json

    {
      "destination": "@username",
      "message": "Command started."
    }

**Response.**

.. code:: http

    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: ...

    {"status": "sent"}
