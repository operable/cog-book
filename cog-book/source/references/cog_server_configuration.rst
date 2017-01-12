Cog Server Configuration
========================

Cog’s behavior can be modified in a number of ways, each governed by a
separate environment variable. This section enumerates all the available
variables and describes their usage.

    **Tip**

    See `The Twelve-Factor App <http://12factor.net>`__ for more
    information about this style of configuration.

``COG_ALLOW_SELF_REGISTRATION``
    Cog will automatically create accounts for new users when set. User
    accounts created this way will still need to be placed into groups
    by an administrator in order to be granted any permissions.

``COG_API_PORT``
    The IP port to listen on for Cog’s REST API. Must be distinct from
    `[COG\_TRIGGER\_PORT] <#COG_TRIGGER_PORT>`__.

    Defaults to ``4000``.

``COG_API_URL_BASE``
    Controls the prefix of URLs generated for the core API. URLs may
    contain a scheme (either ``http`` or ``https``), a host, an optional
    port (defaulting to ``80`` for ``http`` and ``443`` for ``https``),
    and an optional path.

    See also `[COG\_SERVICE\_URL\_BASE] <#COG_SERVICE_URL_BASE>`__ and
    `[COG\_TRIGGER\_URL\_BASE] <#COG_TRIGGER_URL_BASE>`__.

``COG_API_URL_HOST``
    **DEPRECATED** Use `[COG\_API\_URL\_BASE] <#COG_API_URL_BASE>`__
    instead!

    Host to be used in generated API URLs. This should be a DNS name or
    IP address at which Cog can be reached externally.

    Defaults to ``localhost``.

    See `[COG\_SERVICE\_URL\_HOST] <#COG_SERVICE_URL_HOST>`__ and
    `[COG\_TRIGGER\_URL\_HOST] <#COG_TRIGGER_URL_HOST>`__ also; these
    are all usually set to the same value, but need not be.

``COG_API_URL_PORT``
    **DEPRECATED** Use `??? <#COG_TRIGGER_API_BASE>`__ instead!

    Port to be used in generated API URLs. This should be where Cog can
    be reached externally.

    Defaults to ``4000``.

    See also `[COG\_API\_URL\_HOST] <#COG_API_URL_HOST>`__ and
    `[COG\_API\_PORT] <#COG_API_PORT>`__.

``COG_BOOTSTRAP_*`` Variables
    The following environment variables are available to automatically
    bootstrap a Cog system at startup without further intervention
    (e.g., it does not require running ``cogctl bootstrap`` afterwards).
    Values for all the ``COG_BOOTSTRAP_*`` variables are required
    (except ``COG_BOOTSTRAP_CHAT_HANDLE``; see below) for the
    bootstrapping to occur, and bootstrapping will *only* occur if the
    system has not already been bootstrapped. Each variable describes an
    attribute of the first user created on the system, which will have
    administrator privileges over the entire system.

    If you wish your bootstrap user to be associated with a chat handle
    for your currently-configured chat provider (see, e.g.,
    `[COG\_SLACK\_ENABLED] <#COG_SLACK_ENABLED>`__ and
    `[COG\_HIPCHAT\_ENABLED] <#COG_HIPCHAT_ENABLED>`__), then set
    ``COG_BOOTSTRAP_CHAT_HANDLE``. If the value is not an existing chat
    handle, an error will be logged, but startup will proceed as usual.

    These are intended for automated installations of Cog (e.g., using
    management software such as Chef, Puppet, and Ansible, and / or
    platforms such as AWS and Heroku). Please note that bootstrapping
    via these variables *will not* generate a ``.cogctl`` file for you;
    you will need to generate one for yourself with the appropriate
    values.

    -  ``COG_BOOTSTRAP_CHAT_HANDLE``

    -  ``COG_BOOTSTRAP_EMAIL_ADDRESS``

    -  ``COG_BOOTSTRAP_FIRST_NAME``

    -  ``COG_BOOTSTRAP_LAST_NAME``

    -  ``COG_BOOTSTRAP_PASSWORD``

    -  ``COG_BOOTSTRAP_USERNAME``

.. _COG_CUSTOM_TEMPLATE_DIR:

``COG_CUSTOM_TEMPLATE_DIR``
    The path to your custom template directory.

    Cog uses a set of common templates to format responses generated
    internally. Some of these templates may be overridden by placing a
    custom version in a directory and setting this var to said
    directory’s path. See
    `??? <#Customizing the standard error template>`__ for more
    information.

``COG_DB_POOL_SIZE``
    Database connection pool size.

    Defaults to ``10``.

``COG_DB_POOL_TIMEOUT``
    Amount of time to wait to checkout a database connection from the
    pool.

    Defaults to ``15000`` ms.

``COG_DB_TIMEOUT``
    Amount of time to wait for execution of a database query to
    complete.

    Defaults to ``15000`` ms.

``COG_DB_SSL``
    Set this environment variable to have Cog connect to its database
    using SSL.

    Defaults to ``false``.

``COG_EMAIL_FROM``
    Email address that emails sent from Cog will be sent from. Necessary
    to enable password resets.

    See also:

    -  `[COG\_SMTP\_VARIABLES] <#COG_SMTP_VARIABLES>`__

    -  `[COG\_PASSWORD\_RESET\_BASE\_URL] <#COG_PASSWORD_RESET_BASE_URL>`__

``COG_HIPCHAT_ENABLED``
    Enables the HipChat chat adapter for integration with HipChat. You
    **MUST** specify **ONE** and only **ONE** chat adapter for Cog.

    See also: `[COG\_SLACK\_ENABLED] <#COG_SLACK_ENABLED>`__

``COG_MQTT_HOST``
    The host (DNS name or IPv4) to listen on for the
    `MQTT <https://mqtt.org>`__ message bus. MQTT is the messaging
    system underlying Cog.

    Defaults to ``127.0.0.1``.

``COG_MQTT_PORT``
    The IP port number to listen on for the `MQTT <https://mqtt.org>`__
    message bus.

    Defaults to ``1883``.

``COG_PASSWORD_RESET_BASE_URL``
    For advanced users

    Optional variable set when configuring password resets. If set Cog
    will send this link with a token appended as a query string,
    ``?token=token``, in the password reset email. This is useful if you
    want to provide a custom ui for resetting passwords.

    See also:

    -  `[COG\_EMAIL\_FROM] <#COG_EMAIL_FROM>`__

    -  `[COG\_SMTP\_VARIABLES] <#COG_SMTP_VARIABLES>`__

``COG_SERVICE_URL_BASE``
    Controls the prefix of URLs generated for services. URLs may contain
    a scheme (either ``http`` or ``https``), a host, an optional port
    (defaulting to ``80`` for ``http`` and ``443`` for ``https``), and
    an optional path.

    See also `[COG\_API\_URL\_BASE] <#COG_API_URL_BASE>`__ and
    `[COG\_TRIGGER\_URL\_BASE] <#COG_TRIGGER_URL_BASE>`__.

``COG_SERVICE_URL_HOST``
    **DEPRECATED** Use
    `[COG\_SERVICE\_URL\_BASE] <#COG_SERVICE_URL_BASE>`__ instead!

    Host to be used in generated service URLs. This should be a DNS name
    or IP address at which Cog can be reached externally.

    Defaults to ``localhost``.

    See `[COG\_API\_URL\_HOST] <#COG_API_URL_HOST>`__ and
    `[COG\_TRIGGER\_URL\_HOST] <#COG_TRIGGER_URL_HOST>`__ also; these
    are all usually set to the same value, but need not be.

``COG_SERVICE_URL_PORT``
    **DEPRECATED** Use
    `[COG\_SERVICE\_URL\_BASE] <#COG_SERVICE_URL_BASE>`__ instead!

    Port to be used in generated service URLs. This should be where Cog
    can be reached externally.

    Defaults to ``4002``.

    See also `[COG\_SERVICE\_URL\_HOST] <#COG_SERVICE_URL_HOST>`__ and
    `??? <#COG_SERVICE_PORT>`__.

``COG_SLACK_ENABLED``
    Enabled the Slack chat adapter for integration with Slack. You
    **MUST** specify **ONE** and only **ONE** chat adapter for Cog.

    See also: `[COG\_HIPCHAT\_ENABLED] <#COG_HIPCHAT_ENABLED>`__

``COG_SMTP_*`` Variables
    You may optionally configure email support via SMTP for Cog.
    Currently Cog only sends emails for password resets], but there may
    be additional features that require email in the future.

    -  ``COG_SMTP_SERVER``

    -  ``COG_SMTP_PORT``

    -  ``COG_SMTP_USERNAME``

    -  ``COG_SMTP_PASSWORD``

    -  ``COG_SMTP_SSL`` (Defaults to ``false``)

    -  ``COG_SMTP_RETRIES`` (Defaults to 1)

       See also:

    -  `[COG\_EMAIL\_FROM] <#COG_EMAIL_FROM>`__

    -  `[COG\_PASSWORD\_RESET\_BASE\_URL] <#COG_PASSWORD_RESET_BASE_URL>`__

``COG_TELEMETRY``
    Whether or not Cog should send an event to the Operable telemetry
    service when it starts. This event contains a unique identifier
    (based on the SHA256 of the UUID for your operable bundle), the Cog
    version number, and the Elixir mix environment (:prod, :dev, etc)
    that Cog is running under. Set this value to ``false`` to disable
    this event from being sent.

    Defaults to ``true``.

``COG_TRIGGER_PORT``
    The IP port to listen on for invocation of triggers. Must be
    distinct from `[COG\_API\_PORT] <#COG_API_PORT>`__.

    Defaults to ``4001``.

``COG_TRIGGER_TIMEOUT_BUFFER``
    Triggers have a configurable timeout, but it is defined from the
    HTTP requestor’s perspective. In order to satisfy this, we build in
    a buffer to account for network round tripping, Cog processing, etc.

    Defaults to ``2`` seconds.

``COG_TRIGGER_URL_BASE``
    Controls the prefix of URLs generated for triggers. URLs may contain
    a scheme (either ``http`` or ``https``), a host, an optional port
    (defaulting to ``80`` for ``http`` and ``443`` for ``https``), and
    an optional path.

    See also `[COG\_API\_URL\_BASE] <#COG_API_URL_BASE>`__ and
    `[COG\_SERVICE\_URL\_BASE] <#COG_SERVICE_URL_BASE>`__.

``COG_TRIGGER_URL_HOST``
    **DEPRECATED** Use
    `[COG\_TRIGGER\_URL\_BASE] <#COG_TRIGGER_URL_BASE>`__ instead!

    Host to be used in generated trigger invocation URLs. This should be
    a DNS name or IP address at which Cog can be reached externally.

    Defaults to ``localhost``.

    See `[COG\_API\_URL\_HOST] <#COG_API_URL_HOST>`__ and
    `[COG\_SERVICE\_URL\_HOST] <#COG_SERVICE_URL_HOST>`__ also; these
    are all usually set to the same value, but need not be.

``COG_TRIGGER_URL_PORT``
    **DEPRECATED** Use
    `[COG\_TRIGGER\_URL\_BASE] <#COG_TRIGGER_URL_BASE>`__ instead!

    Port to be used in generated trigger invocation URLs. This should be
    where Cog can be reached externally.

    Defaults to ``4001``.

    See also `[COG\_TRIGGER\_URL\_HOST] <#COG_TRIGGER_URL_HOST>`__ and
    `[COG\_TRIGGER\_PORT] <#COG_TRIGGER_PORT>`__.

``DATABASE_URL``
    The URL at which Cog may access its PostgreSQL database. Cog uses
    the `Ecto <https://hexdocs.pm/ecto/Ecto.Repo.html>`__ library, and
    the URL takes the form of:

    \`\`\`
    ecto://$POSTGRES\_USER:$POSTGRES\_PASSWORD@$DB\_HOST:$DB\_PORT/$DB\_NAME
    \`\`\`

    See also:

    -  `[POSTGRES\_USER] <#POSTGRES_USER>`__

    -  `[POSTGRES\_PASSWORD] <#POSTGRES_PASSWORD>`__

``ENABLE_SPOKEN_COMMANDS``
    If ``true``, allows Cog to respond to commands prefixed with ``!``
    instead of only via direct mentions.

    Compare

    ::

        !help

    with

    ::

        @clever_bot_name help

    Defaults to ``true``.

``HIPCHAT_API_TOKEN``
    Token for HipChat’s V2 REST API. The token must have the following
    scopes: Send Message, Send Notification, View Group, View Messages,
    View Room.

``HIPCHAT_JABBER_ID``
    The Jabber ID, also called a ``jid``, assigned to the bot’s HipChat
    account.

``HIPCHAT_JABBER_PASSWORD``
    The password assigned to the bot’s HipChat account.

``HIPCHAT_NICKNAME``
    The mention name assigned to the bot’s HipChat account. The name can
    be found on the bot account’s profile page.

All of the above settings can be found on the HipChat account details
page. To view this page for your bot’s account simply log in to
HipChat’s site using your bot credentials and then open
``https://<organization name>.hipchat.com/account`` where
``<organization name>`` is the name of your HipChat organization.

``HIPCHAT_API_ROOT``
    The root URL of HipChat’s V2 REST API. Defaults to
    https://api.hipchat.com/v2.

``HIPCHAT_CHAT_HOST``
    The host name of HipChat’s XMPP API. Defaults to
    ``chat.hipchat.com``.

``HIPCHAT_CONF_HOST``
    The host name of HipChat’s XMPP multi-user room service. Defaults to
    ``conf.hipchat.com``.

``POSTGRES_PASSWORD``
    The password for connecting to Cog’s PostgreSQL database.

    See also:

    -  `[DATABASE\_URL] <#DATABASE_URL>`__

    -  `[POSTGRES\_USER] <#POSTGRES_USER>`__

``POSTGRES_USER``
    The user to connect to Cog’s PostgreSQL database.

    See also:

    -  `[DATABASE\_URL] <#DATABASE_URL>`__

    -  `[POSTGRES\_PASSWORD] <#POSTGRES_PASSWORD>`__

``SLACK_API_TOKEN``
    Real-Time Messaging (RTM) API token used to connect to Slack. To
    obtain one, go to
    ``https://<your_slack-team>.slack.com/apps/manage/custom-integrations``
    and click on ``Bots``.

    It *must* be an RTM API token; a token for the REST API will *not*
    work.
