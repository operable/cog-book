Templates
=========

*Formatting pipeline output for humans!*

In contrast to traditional command-line programs, the output of a Cog
command is not plain text, but a JSON object. This common structure
makes it easy to chain commands together into pipelines because
downstream commands can easily reach into the JSON output to extract the
data they need, without having to jump through the various text
manipulation steps that are so frequently part of traditional
command-line pipelines. When it’s time to present the final output of a
pipeline, however, we often want something a bit more user-friendly than
a dump of JSON data in our chat window.

To address this, Cog commands have the ability to specify a template
that will be used to process the final pipeline output into a more
readable format. This allows commands to return rich JSON objects for
maximum flexibility in pipelines, but also condense these objects down
to the salient information that humans need in chat ("Bundle *foo*,
version *1.0.0* was enabled", for example).


.. _basic_greenbar_syntax:

Basic Greenbar Syntax
---------------------

The template language used by Cog is
`Greenbar <https://github.com/operable/greenbar>`__, a language created
by Operable for the needs of Cog. It is probably best described as a
Markdown variant, with support for ERB-like tags.

Many familiar Markdown features are available, including boldface,
italics, ordered and unordered lists, and monospace formatting; even
tables. Iteration and conditional logic (among other features) are
achieved through the use of "tags". Data from result objects can be
accessed through variable references. This example will illustrate many
Greenbar features:

**Example Greenbar Template.**

.. commenting out ''.. code:: Markdown' and adding '::' below.
.. The block below wasn't displaying in the html.  I think it's related to the missing Markdown lexer.  .RJS.

::

    ~if cond=length($results) == 1~
    The _only_ member of the group is **~$results[0].username~**.
    ~end~
    ~if cond=length($results) > 1~
    The group has the following members:
    ~each var=$results as=user~
    1. ~$user.username~
    ~end~
    ~end~

Note that all Greenbar instructions are enclosed in ``~`` characters.
Some, like ``~if~`` and ``~each~`` have bodies, with corresponding
``~end~`` terminators; bodies may contain plain text, or other Greenbar
instructions. Variable dereferencing is achieved with the use of the
``$`` operator within Greenbar instructions. Complex objects can be
navigated using familiar dot notation, and individual array members can
be addressed by a zero-based index. Markdown does not require special
Greenbar instructions, but is used directly (observe the italics on
"only", the bolding of the single user’s name, and the generation of an
ordered list in the ``~each~`` iterator). Note also the presence of the
top-level "results" key, containing all the output of the Cog pipeline.

If you’re looking for more information on how to write templates, skip
on down to :ref:`Advanced Greenbar Usage <advanced_greenbar_usage>`.

Overall Template Processing Logic
---------------------------------

In order to write effective templates, it helps to understand a bit
about how Cog processes the output of pipelines, how templates are
chosen, and how pipeline data is presented to the template.

All pipelines return a "results" list
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For all successful pipeline runs, Cog will return a single JSON object
to the template. This object will have a "results" key, which is always
a list of objects returned from individual command invocations (it’s a
list whether there is only a single result object or many).

Commands can specify a template when they return to Cog
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When each command runs, it has the option of specifying a template to
use when formatting the output by returning a ``COG_TEMPLATE`` value in
the output. The name of the template is resolved relative to the bundle
the command is a member of. If no template is specified, then Cog will
fall back to one of two "common" templates. If the command returns bare
text (instead of JSON, as is customary), then a special "text" template
is used. On the other hand, if JSON is returned, then the "raw" template
is used, which will pretty-print the results.

Last output "wins"
~~~~~~~~~~~~~~~~~~

The return value of every Cog command invocation can specify a template
to use, but pipelines can trigger multiple invocations in the course of
processing. That can theoretically result in multiple templates being
specified.

Templates are only truly needed at the end of a pipeline, however. If a
command in the middle of a pipeline declares that its output should be
formatted with the "foo" template, we don’t care, because we know that
output is going to be modified further by the downstream commands. As
soon as Cog wraps up one pipeline stage and moves on to the next, all
template information collected to that point is discarded.

With respect to templating, it is the final stage that we care about.
With Cog’s current implementation, each invocation can theoretically
specify a different template; in reality, though, only the template
specified by the final invocation is used to template all the data.

Meta-templates, not Templates
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cog’s templates are not actually templates, but rather "meta-templates".
They do not generate text, but rather *directives*, instructions on how
to render text. This allows individual chat providers to determine
exactly how to format a given template. For example, the Slack provider
can interpret a ``bold`` directive as ``*bold text*``, while a HipChat
provider can interpret the same directive as ``<b>bold text</b>``.

.. note:: You can see how Greenbar directives are processed for Slack in the
    code
    `here <https://github.com/operable/cog/blob/72308c31f49e8d8369f48ec1dd932403117e232c/lib/cog/chat/slack/template_processor.ex>`__.

By using this architecture, command authors only need to write a single
template, which each chat provider can interpret in the best way for its
host platform, instead of having to supply a template for each chat
provider individually.

.. note:: The rendering of Greenbar templates to general directives, which are
    then processed by chat adapter-specific processors, is analogous to
    the interpretation of Java bytecode on platform-specific VMs, or the
    rendering of OpenGL directives by different graphics processors.

.. _advanced_greenbar_usage:

Advanced Greenbar Usage
-----------------------

Greenbar includs a variety of tags to help you better organze your
output and also fully utilize the formatting options available from your
chat provider. To view more information about all tags that come with
Greenbar with examples for each, jump down to the Reference section
titled :doc:`../references/greenbar_tags`. And, if you haven’t been able to find
the tag you’re looking for, Greenbar also supports custom tags.

.. note:: While this document gives an overview of Greenbar and gives you a
    reference for tags you can use, we’re still pretty short on
    examples. If you want to see what some real life templates look like
    and all the ways tags can be used to accomplish normal formatting,
    take a look at all the `templates used by commands included in
    Cog <https://github.com/operable/cog/tree/master/priv/templates>`__.

Writing a custom tag
--------------------

All of the tags we’ve covered were implemented in Elixir using the
``Greenbar.Tag`` module, which you can also use to write your own custom
tags. Before we dive into writing our own, let’s take a look at a
super-simple example, the ``~br~`` tag:

.. code:: Elixir

    defmodule Greenbar.Tags.Break do
      use Greenbar.Tag, name: "br"

      def render(_id, _attrs, scope) do
        {:halt, %{name: :newline}, scope}
      end
    end

First, we ``use Greenbar.Tag`` to set the name of the tag that we’ll use
in the template. Then, we implement ``render`` which returns a newline.
The ``:halt`` symbol in the tuple returned means that the tag has
finished rendering and we can continue processing the rest of the
template. There are a few more ways we can output values which are more
useful in tags that accept a body as we’ll see in the next example.

Now to implement our own tag. Let’s build a tag that converts the body
to uppercase. For a template like this:

::

  ~upcase~
  hello world
  ~end~

we’ll expect the final result to be:

::

  HELLO WORLD

To start we can open up a new file named ``upcase.ex`` and start out
with an empty module and ``use Greenbar.Tag`` to set the name.

.. code:: Elixir

    defmodule Upcase do
      use Greenbar.Tag, name: "upcase"
    end

Next, we need to implement the ``render`` function using a new tuple,
``{:once,
scope, child_scope}``. This creates a new scope for our tag body.

.. code:: Elixir

    def render(_id, _attrs, scope) do
      child_scope = new_scope(scope)
      {:once, scope, child_scope}
    end

I know what you’re thinking, "Where’s the ``String.upcase`` call?" Well,
the render call is useful for changing scope and returning pre-defined
results, but if you want to modify the body of a tag, you’ll need to
implement a ``post_body`` function. ``post_body`` gives you access to
the attributes of the tag, the outside scope, the scope of the body and
a buffer containing all the parsed items from the template. All we need
to do is to iterate over the items in the buffer and upcase anything
that contains text.

.. code:: Elixir

    def post_body(_id, _attrs, scope, _body_scope, %Buffer{items: items}) do
      {:ok, scope, %Buffer{items: Enum.map(items, &upcase_directive/1)}}
    end

    def upcase_directive(%{name: :text, text: text} = directive),
      do: %{directive | text: String.upcase(text)}
    def upcase_directive(directive),
      do: directive

.. note:: You’ll also have to include ``alias Greenbar.Runtime.Buffer`` at the
    top of the module.

And that should do it. Your final custom tag module will look like the
following:

.. code:: Elixir

    defmodule Cog.Tags.Upcase do
      use Greenbar.Tag, name: "upcase", body: true
      alias Greenbar.Runtime.Buffer

      def render(_id, _attrs, scope) do
        child_scope = new_scope(scope)
        {:once, scope, child_scope}
      end

      def post_body(_id, _attrs, scope, _body_scope, %Buffer{items: items}) do
        {:ok, scope, %Buffer{items: Enum.map(items, &upcase_directive/1)}}
      end

      def upcase_directive(%{name: :text, text: text} = directive),
        do: %{directive | text: String.upcase(text)}
      def upcase_directive(directive),
        do: directive
    end

.. note:: Modifying Cog’s source code to include custom tags is not ideal and
    wont be easy for everyone to include in their deploy process. Future
    versions of Cog will have a better way to include custom tags
    without modifying Cog or Greenbar, which can be more easily used
    with our Docker Compose install, for example.

To use this with Cog, we’re going to need to include this module in the
Cog codebase and set it as an available tag when creating the
``Greenbar.Engine``. Move the ``upcase.ex`` file we just created to
``lib/cog/tags/upcase.ex`` and rename the module to ``Cog.Tags.Upcase``.
Now open up ``lib/cog/template/new/evaluator.ex`` and scroll down to the
bottom of the file to find the ``do_evaluate`` function. We need to add
the ``upcase`` tag to the engine. Directly after the line where we
create the engine, include this line to add our tag:

.. code:: Elixir

    {:ok, engine} = Engine.add_tag(engine, Cog.Tags.Upcase)

The end result should look like:

.. code:: Elixir

    def do_evaluate(name, source, data) do
      {:ok, engine} = Engine.new
      {:ok, engine} = Engine.add_tag(engine, Cog.Tags.Upcase)
      engine
      |> Engine.compile!(name, source)
      |> Engine.eval!(name, data)
    end

And that’s it, just restart Cog and you can use your new ``~upcase~``
tag in any template.

.. _Customizing_the_standard_error_template:

Customizing the standard error template
---------------------------------------

Cog uses a standard template to render errors that might occur when
processing a pipeline. For example, when a user types the name of a
command that does not exists, or if a command were to crash
unexpectedly. The standard template contains a lot of information that
is useful when developing bundles, but may a bit to much info for the
average user. For this reason, it can be easily customized.

Configuring
~~~~~~~~~~~

Configuring Cog to use a custom error template is a two step process.
First create a template called ``error.greenbar`` and place it in an
empty directory accessible to Cog. Then set
:ref:`COG_CUSTOM_TEMPLATE_DIR<COG_CUSTOM_TEMPLATE_DIR>` to the path of said directory. After
setting the env var you can update or remove the custom template file
directly. No Cog restarts are required.

error.greenbar
~~~~~~~~~~~~~~

Like all templates in Cog, the standard error template is written in
greenbar. See :ref:`Basic Greenbar Syntax <basic_greenbar_syntax>` for more info. Unlike
templates defined for commands though, the standard error template does
not receive a "results" list. Instead it receives a single object
containing information about the error.

The error object contains the following keys:

id
    The id of the pipeline.

started
    The time stamp for the start of the pipeline.

initiator
    The username of the one who initiated the pipeline.

pipeline\_text
    The complete text of the pipeline.

error\_message
    The error message returned by the pipeline.

planning\_failure
    When a pipeline fails during it’s planning stage, ie during variable
    binding or when interpreting options, this will contain the portion
    of the pipeline that generated the error. Otherwise this will be
    ``false``.

execution\_failure
    Similar to ``$planning_failure``; when a pipeline fails during
    execution of the pipeline, this will contain the portion of the
    pipeline that caused the error. Otherwise this is set to ``false``.

**The default error.greenbar as an example.**

.. commenting out ''.. code:: Markdown' and adding '::' below.
.. The block below wasn't displaying in the html.  I think it's related to the missing Markdown lexer.  .RJS.

::

    ~attachment title="Command Error" color="#ff3333" Caller=$initiator Pipeline=$pipeline_text "Pipeline ID"=$id Started=$started~
    ~if cond=$planning_failure ~
    The pipeline failed planning the invocation:
    ~br~
    ```
    ~$planning_failure~
    ```
    ~end~
    ~if cond=$execution_failure~
    The pipeline failed executing the command:
    ~br~
    ```
    ~$execution_failure~
    ```
    ~end~
    ~br~
    ~br~
    The specific error was:
    ~br~
    ```
    ~$error_message~
    ```
    ~end~
