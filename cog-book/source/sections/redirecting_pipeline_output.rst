Redirecting Pipeline Output
===========================

*If it’s good enough for your terminal, it’s good enough for your chat
bot*

Normally when you execute a chat command, the output will be sent to the
same place you typed the command. That is, if you’re talking with Cog in
your ``#general`` Slack channel, output will show up in ``#general`` as
well.

However, it can be useful to have output go to another location (or even
multiple locations!). Cog provides two operators for this: ``>`` for
single-destination redirects, and ``*>`` for multiple destinations.

This can be great for ensuring that everyone that needs to know what’s
going on is clued in. As it turns out, it’s also great for trolling your
coworkers, as we’ll see icon:smile-o[]

Redirection Destinations
------------------------

Chat User
    You can direct output to an individual user by using their chat
    handle as a destination.

    **Cog.**

    .. code:: text

        !echo "Hi, boss!" > @imbriaco

    The output will show up in a one-on-one chat conversation between
    the Cog bot and the user.

    One important thing to note is that this target is the *chat handle*
    of the person, and not their Cog username (which may be different).
    Another thing to be aware of is the destination must be formatted
    according to your chat platform’s conventions for mentioning users.
    For example, if you’re using Slack, ``@imbriaco`` would be valid,
    but just ``imbriaco`` (without the ``@``) would be *invalid*. On the
    other hand, If you’re using IRC, which has no such conventions, you
    would use just the bare chat handle (here, ``imbriaco``).

Chat Room / Channel
    Instead of sending the output of a command to only one person, you
    can alternatively send it to a chat room. The notation is similar to
    that for individual users:

    **Cog.**

    .. code:: text

        !echo "I love our operations team!" > #ops

    Just as with user redirection destinations, your chat room’s name
    must be formatted according to the expected conventions of your chat
    provider (e.g. ``#ops`` but not ``ops`` on Slack, etc.)

.. _here_alias:

**here** Alias
    Cog provides a special alias ``here`` that is shorthand for
    "wherever the command came from". In fact, if you provide no
    redirect destinations, Cog will effectively treat it as though you
    redirected to ``here``. That is, ``!echo "Hello"`` and
    ``!echo "Hello" > here`` will behave identically. If you do provide
    explicit redirect destinations, however, you will need to provide
    ``here`` if you would also like output to go to wherever you are
    currently typing.

    While this is sometimes useful in chat, it becomes more useful when
    setting up pipelines that are triggered remotely.

    This alias is always the literal string ``here``, regardless of chat
    platform.

.. _me_alias:

**me** Alias
    Similar to ``here``, the ``me`` alias is a shortcut for sending
    output to yourself.

    This alias is always the literal string ``me``, regardless of chat
    platform.

.. _chat_URLs:

**chat://** URLs
    Under the hood, a user or room redirect destination like
    ``#general`` is actually treated as though it were typed
    ``chat://#general``. This URL syntax instructs Cog to use the
    currently-configured chat adapter to send output to ``#general``,
    whatever that means for that specific chat adapter.

    This additional syntax is unnecessary when you are interacting with
    Cog via chat; ``!echo "Hello" > #general`` expands to
    ``!echo "Hello" > chat://#general``, because Cog defaults to sending
    output via the same adapter it received the input.

    However, this URL syntax becomes required when you interact with Cog
    through non-chat means, such as by triggering pipelines via the HTTP
    adapter. In that case, you may want output to show up in chat, but
    the HTTP adapter does not know how to resolve ``#general`` to your
    Slack channel. By using ``chat://#general``, you’re instructing Cog
    to hand off output processing to your chat adapter instead.

Multiple Redirect Destinations
------------------------------

By altering our syntax slightly, we can redirect to any number of
destinations, which is useful for keeping multiple parties in the loop.

If you’re in the middle of an incident, you could imagine using a
notional ``tweet`` command to alert users of your service, while using
redirection to let your support and operations teams know that
something’s up, all at the same time:

**Cog.**

.. code:: text

    !tweet "Investigating slow API response times" *> here #support #ops @brent

Instead of ``>``, we use ``*>``. Now the utility of aliases comes into
play; we would also probably like a record of what’s happening in the
current channel, as well as bringing others into the situation.

Easter Egg: Trolling Your Coworkers
-----------------------------------

As we stumbled upon here at Operable, redirection can also be used to
troll your coworkers. Simply type commands in a private chat with the
bot (where nobody can see what you’re doing) and redirect the output to
the destination(s) of your choice.

**Cog.**

.. code:: text

    !echo "I'm sorry Dave; I'm afraid I can't do that." > #general

Remember: with great power comes great responsibility!
