Audit Log Events
================

As Cog processes requests, both HTTP API requests, as well as command pipelines, it emits events throughout the processing lifecycle. These are recorded in Cog's event log as JSON maps. Many of the keys are shared across events, but some will be specific to a particular event type. The events that Cog currently emits, as well as a description of their structure, are enumerated here.

API Events
----------

These events are emitted in the process of handling an HTTP request.

API Event Types
^^^^^^^^^^^^^^^

* `api_request_started`
* `api_request_authenticated`
* `api_request_finished`

Common Fields
^^^^^^^^^^^^^

All API events contain the following fields, regardless of type.

request_id
    The unique identifier assigned to the request. All events emitted
    in the processing of the request will share the same ID.

event
    Label indicating which API request lifecycle event is being
    recorded.

timestamp
    When the event was created, in UTC, as an ISO-8601 extended-format
    string (e.g. `"2016-01-07T15:08:00.000000Z"`).

elapsed_microseconds
    Number of microseconds elapsed since beginning of request
    processing to the creation of this event.

http_method
    The HTTP method of the request being processed as an uppercase
    string.

path
    The path portion of the request URL.

API Event-specific Data
^^^^^^^^^^^^^^^^^^^^^^^

In addition to the common fields, each individual API event type can
have additional type-specific fields.

`api_request_started` Event
    No extra fields

`api_request_authenticated` Event
    user
        The Cog username of the authenticated requestor. Note that
        this is not a chat handle.

`api_request_finished` Event
    status
        The HTTP status code of the response.

Pipeline Events
---------------

Whenever Cog processes a command pipeline, whether it arrives from a
chat client or was initiated using a trigger, it generates a number of
events.

Pipeline Event Types
^^^^^^^^^^^^^^^^^^^^

* `pipeline_initialized`
* `command_dispatched`
* `pipeline_succeeded`
* `pipeline_failed`

Common Fields
^^^^^^^^^^^^^

All pipeline events share the following fields:

pipeline_id
    The unique identifier of the pipeline emitting the event. Can be
    used to correlate events from the same pipeline instance.

event
    Label indicating which pipeline lifecycle event is being recorded.

timestamp
    When the event was created, in UTC, as an ISO-8601 extended-format
    string (e.g. `"2016-01-07T15:08:00.000000Z"`).

elapsed_microseconds
    Number of microseconds elapsed since beginning of pipeline
    execution to the creation of this event.

Pipeline Event-specific Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In addition to the common fields, each individual pipeline event type
can have additional type-specific fields.

`pipeline_initialized` Event
    command_text
        The text of the entire pipeline, as typed by the user. No
        variables will have been interpolated or bound at this point.

    provider
        The chat provider being used

    handle
        The provider-specific chat handle of the user issuing the
        command.

    cog_user
        The Cog-specific username of the invoker of issuer of the
        command. May be different than the provider-specific handle.

`command_dispatched` Event
    command_text
        The text of the command being dispatched to a Relay. In
        contrast to `pipeline_initialized` above, here, variables
        _have_ been interpolated and bound. If the user submitted a
        pipeline of multiple commands, a `command_dispatched` event
        will be created for each discrete command.

    relay
        The unique identifier of the Relay the command was dispatched
        to.

    cog_env: JSON string
        The calling environment sent to the command. The value is
        presented formally as a string, not a map.

`pipeline_succeeded` Event
    result: JSON string
        The JSON structure that resulted from the successful
        completion of the entire pipeline. This is the raw data
        produced by the pipeline, prior to any template
        application. The value is presented formally as a string, not
        a list or map.

`pipeline_failed` Event
    error
        A symbolic name of the kind of error produced.

    message
        Additional information and detail about the error.
