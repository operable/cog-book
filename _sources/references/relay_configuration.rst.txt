Relay Configuration
===================

Relay can be configured using a configuration file. As with Cog, most of
Relay’s configuration entries can be controlled via environment
variables. For each key in the configuration file, the corresponding
environment variable is the upper-cased key, prepended with ``RELAY_``.
Thus, the key ``max_concurrent`` can be overridden using the environment
variable ``RELAY_MAX_CONCURRENT``, and so on.

.. warning:: The sole exception to this is the Relay "execution env" setting. If
    used, this *must* be set in the configuration file; there is no
    corresponding environment variable.

.. note:: An annotated example of a complete configuration file is kept in
    Relay’s GitHub repo
    `here <https://github.com/operable/go-relay/blob/master/example_relay.conf>`__.

.. _DOCKER_API_VERSION:

``DOCKER_API_VERSION``
    Controls what version of the Docker API should be used when
    interacting with Docker.

    Defaults to 1.23

.. _RELAY_COG_ENABLE_SSL:

``RELAY_COG_ENABLE_SSL``
    Encrypts MQTT traffic between Relay and Cog.

    Defaults to ``false``.

.. _RELAY_COG_HOST:

``RELAY_COG_HOST``
    The host name or IP address of the Cog server.

    Defaults to ``127.0.0.1``. See also :ref:`[COG_MQTT_HOST] <COG_MQTT_HOST>`.

.. _RELAY_COG_PORT:

``RELAY_COG_PORT``
    The MQTT listen port of the Cog server.

    Defaults to ``1883``. See also :ref:`[COG_MQTT_PORT] <COG_MQTT_PORT>`.

.. _RELAY_COG_REFRESH_INTERVAL:

``RELAY_COG_REFRESH_INTERVAL``
    Controls how often Relay refreshes its list of installed bundles and
    Docker images.

    Valid time units are ``s`` (seconds), ``m`` (minutes), and ``h``
    (hours).

    Defaults to ``15m``. Consider reducing this interval to ``1m`` or
    less when frequently updating bundles.

.. _RELAY_COG_SSL_CERT_PATH:

``RELAY_COG_SSL_CERT_PATH``
    Path to the Cog server’s SSL certificate.

    Enables certificate verification if set.

.. _RELAY_COG_TOKEN:

``RELAY_COG_TOKEN``
    Shared secret between Cog and a given Relay.

    Corresponds to the ``TOKEN`` argument used when creating a Relay via
    ``cogctl``.

.. note:: This is a required setting.

.. _RELAY_DOCKER_CLEAN_INTERVAL:

``RELAY_DOCKER_CLEAN_INTERVAL``
    Controls how frequently Relay will remove unused Docker containers.

    Uses the same time unit notation as
    :ref:`[RELAY\_COG\_REFRESH\_INTERVAL] <RELAY_COG_REFRESH_INTERVAL>`.

    Defaults to ``5m``.

.. _RELAY_DOCKER_CONTAINER_MEMORY:

``RELAY_DOCKER_CONTAINER_MEMORY``
    Controls how much memory (in megabytes) is allocated to each Docker
    container Relay uses to execute a command.

    Docker requires a minimum of 4MB per container.

    Defaults to ``16``.

.. _RELAY_DOCKER_REGISTRY_HOST:

``RELAY_DOCKER_REGISTRY_HOST``
    Docker image registry host name.

    Defaults to ``index.docker.io``.

.. _RELAY_DOCKER_REGISTRY_EMAIL:

``RELAY_DOCKER_REGISTRY_EMAIL``
    Email address credential used to access an authenticating Docker
    registry.

.. _RELAY_DOCKER_REGISTRY_USER:

``RELAY_DOCKER_REGISTRY_USER``
    Username credential used to access an authenticating Docker
    registry.

.. _RELAY_DOCKER_REGISTRY_PASSWORD:

``RELAY_DOCKER_REGISTRY_PASSWORD``
    Password credential used to access an authenticating Docker
    registry.

.. note:: ``RELAY_DOCKER_REGISTRY_EMAIL``, ``RELAY_DOCKER_REGISTRY_USER``, and
    ``RELAY_DOCKER_REGISTRY_PASSWORD`` are required when using Relay
    with private Docker repositories or private registries.

.. _RELAY_DOCKER_SOCKET_PATH:

``RELAY_DOCKER_SOCKET_PATH``
    Location of Docker’s Unix socket. Must begin with either ``unix://``
    or ``tcp://``.

    Defaults to ``unix:///var/run/docker.sock``.

.. _RELAY_DOCKER_USE_ENV:

``RELAY_DOCKER_USE_ENV``
    Controls whether or not Relay uses environment variables to set up
    its Docker connection. If ``true``, Relay will use the environment
    variables ``DOCKER_HOST``, ``DOCKER_TLS_VERIFY``, and
    ``DOCKER_CERT_PATH`` to connect.

.. note:: This is a required setting when using Relay with Docker running
    inside `docker-machine <https://docs.docker.com/machine>`__.

.. _RELAY_ENABLED_ENGINES:

``RELAY_ENABLED_ENGINES``
    Comma separated list of command execution engines. Valid engine
    names are:

    -  ``native``: Runs commands distributed as native executables
       installed directly on the Relay host.

    -  ``docker``: Runs commands distributed as Docker container images

       Defaults to ``native,docker``. At least one engine must be
       enabled.

.. _RELAY_ID:

``RELAY_ID``
    UUID assigned to the Relay.

.. note:: This is a required setting.

.. _RELAY_LOG_JSON:

``RELAY_LOG_JSON``
    Controls if Relay logs in plain text or JSON.

    Defaults to ``false``.

.. _RELAY_LOG_LEVEL:

``RELAY_LOG_LEVEL``
    Controls logging verbosity.

    Defaults to ``info``.

.. _RELAY_LOG_PATH:

``RELAY_LOG_PATH``
    Controls where Relay sends its log output. Valid values are:

    -  Any valid file path

    -  ``stdout`` or ``console``

    -  ``stderr``

       Defaults to ``console``.

.. _RELAY_MAX_CONCURRENT:

``RELAY_MAX_CONCURRENT``
    Maximum number of concurrent command invocations.

    Defaults to ``16``.

.. _RELAY_MANAGED_DYNAMIC_CONFIG:

``RELAY_MANAGED_DYNAMIC_CONFIG``
    Controls whether or not Relay pulls dynamic configuration for
    installed command bundles from Cog.

    If set to true, Relay will retrieve dynamic configuration files from
    the Cog server, instead of relying on files placed on the Relay host
    itself. Configuration changes can be submitted to Cog via the API,
    and will be picked up by Relay when it checks in periodically. See
    :ref:`[RELAY\_MANAGED\_DYNAMIC\_CONFIG\_INTERVAL] <RELAY_MANAGED_DYNAMIC_CONFIG_INTERVAL>`.

    Defaults to ``true``.

.. _relay_dynamic_config_root:

``RELAY_DYNAMIC_CONFIG_ROOT``
    File path used to store dynamic bundle configuration files. A
    missing or empty value disables this feature. Nonexistent paths will
    be created on first use.

.. _relay_managed_dynamic_config_interval:

``RELAY_MANAGED_DYNAMIC_CONFIG_INTERVAL``
    Controls how often Relay polls Cog for dynamic configuration
    updates.

    Uses the same time units as
    :ref:`[RELAY\_COG\_REFRESH\_INTERVAL] <RELAY_COG_REFRESH_INTERVAL>`.

    Defaults to ``5s``.

.. note:: This setting only takes effect when managed dynamic configuration is
    enabled.
