Greenbar Tags
=============

if
--

Provides a small set of operators to express conditional logic.
Conditionally evaluates its body based on the value of the ``cond``
attribute.

Example
~~~~~~~

::

  ~if cond=$doit bound?`~
  Hello there!
  ~`end`~

Given the variable ``$doit`` is bound, the above template would produce:

::

  Hello there!

Given that the variable ``$doit`` is not bound, the above template would
produce an empty string.

Operators
~~~~~~~~~

+--------------------------+--------------------------+--------------------------+
| Symbol                   | Name                     | Variable value types     |
+--------------------------+--------------------------+--------------------------+
| :---                     | :---                     | :---                     |
+--------------------------+--------------------------+--------------------------+
| >                        | greater than             | int, float               |
+--------------------------+--------------------------+--------------------------+
| >=                       | greater than equal       | int, float               |
+--------------------------+--------------------------+--------------------------+
| <                        | less than                | int, float               |
+--------------------------+--------------------------+--------------------------+
| ⇐                        | less than equal          | int, float               |
+--------------------------+--------------------------+--------------------------+
| ==                       | equal                    | int, float, string       |
+--------------------------+--------------------------+--------------------------+
| !=                       | not equal                | int, float, string       |
+--------------------------+--------------------------+--------------------------+
| bound?                   | is bound                 | any                      |
+--------------------------+--------------------------+--------------------------+
| empty?                   | is empty                 | list, map                |
+--------------------------+--------------------------+--------------------------+

Each
----

Iterates over a list binding each item to a variable scoped to the tag’s
body. Uses the value of the ``as`` attribute as the name of the variable
during each iteration. If not provided it defaults to ``item``.

Examples
~~~~~~~~

Using the default body variable ``item``:

::

  ~each var=$users~
  First Name: ~$item.first_name~
  Last Name: ~$item.last\_name~
  ~end~

Customizing the body variable:

::

  ~each var=$users as=user~
  First Name: ~$user.first\_name~
  Last Name: ~$user.last\_name~
  ~end~

Given the variable ``$users`` is bound to
``[%{"first_name" => "John", "last_name"
=> "Doe"}]`` then both of the above templates would produce:

::

  First Name: John
  Last Name: Doe

Join
----

Iterates over a list, joining the rendered items with the value of the
``with`` attribute, which defaults to ``", "``. Similar to the ``each``
tag, you may also provide an ``as`` attribute which sets the name of the
variable scoped to the body of the tag.

Examples
~~~~~~~~

Create a comma-delimited list

::

  ~join var=$names~~$item~~end~

Given that the variable ``$names`` is bound to
``["Mark", "Kevin", "Shelton"]`` then the above template would produce:

::

  Mark, Kevin, Shelton

Specify a custom joiner

::

  ~join var=$names with="-"~~$item~~end~

Custom binding

::

  ~join var=$names as=name~~$name~~end~

Bodies can contain arbitrary instructions

::

  ~join var=$users~~$item.profile.username~~end~

Count
-----

Returns the size of the referenced variable. When referencing lists the
size is the length of the list. For maps, size is the number of the
map’s unique keys. Any other value type will display "N/A".

Examples
~~~~~~~~

::

  There are ~count var=$users~ users.

Given that the variable ``$users`` is bound to
``[{ "name": "Mark" }, { "name":
"Kevin" }]`` then the above template would produce:

::

  There are 2 users.

Given that the variable ``$users`` is bound to
``{ "imbriaco": 1, "kevsmith": 2,
"shelton": 3 }`` then the above template would produce:

::

  There are 3 users.

Break
-----

Inserts a hard newline into the rendered template. This can be useful to
work around situtions where Markdown consolidates newlines.

Examples
~~~~~~~~

Normally Markdown will combine two code blocks into one if they are
separated by a single newline.

::

  `This is a line of code`
  `This is another line of code`


will render as

::

  This a line of codeThis is another line of code

::

  `This is a line of code`
  ~br~
  `This is another line of code`

will render as

::

  This is a line of code
  This is another line of code

Attachment
----------

Wraps body in an attachment directive. The initial design is heavily
influenced by Slack’s attachment API.

Attributes
~~~~~~~~~~

+--------------------------------------+--------------------------------------+
| Name                                 | Description                          |
+--------------------------------------+--------------------------------------+
| title                                | Attachment title                     |
+--------------------------------------+--------------------------------------+
| title\_url                           | Optional title link URL              |
+--------------------------------------+--------------------------------------+
| color                                | Color to be used when rendering      |
|                                      | attachment (interpretation may vary  |
|                                      | by provider)                         |
+--------------------------------------+--------------------------------------+
| image\_url                           | Link to image asset (if any)         |
+--------------------------------------+--------------------------------------+
| author                               | Author name                          |
+--------------------------------------+--------------------------------------+
| pretext                              | Preamble text displayed before       |
|                                      | attachment body                      |
+--------------------------------------+--------------------------------------+
| footer                               | Brief text that appears as the       |
|                                      | attachment’s footer                  |
+--------------------------------------+--------------------------------------+

Any other attributes will be interpreted as custom fields and included
in the attachments' ``fields`` field. Custom fields have the following
structure:

.. code-block:: json

  {
    "title": <attribute\_name>,
    "value": <attribute\_value>,
    "short": false
  }

Examples
~~~~~~~~

The template

::

  ~attachment title="VM Use By Region" runtime=$timestamp~
  |Region|Count|
  |---|---|
  ~each var=$regions as=region~
  |~$region.name~|~$region.vm_count~|
  ~end~
  ~end~

when executed with the data

::

  %{"timestamp" => "Mon Sep 12 13:06:57 EDT 2016",
   "regions" => [%{"name" => "us-east-1", "vm_count" => 113},
               %{"name" => "us-west-1", "vm_count" => 105}]}

generates the rendering directives

::

  [%{name: :attachment,
     title: "VM Use By Region",
     fields: [%{short: false,
                title: "runtime",
                value: "Mon Sep 12 13:06:57 EDT 2016"}],
                children: [%{name: :table, children: [%{name: :table_header,
                                    children: [%{name: :table_cell,
                                             children: [%{name: :text, text: "Region"}]},
                                           %{name: :table_cell,
                                             children: [%{name: :text, text: "Count"}]}]},
                              %{name: :table_row,
                                children: [%{name: :table_cell,
                                             children: [%{name: :text, text: "us-east-1"}]},
                                           %{name: :table_cell,
                                             children: [%{name: :text, text: "113"}]}]},
                              %{name: :table_row,
                                children: [%{name: :table_cell,
                                             children: [%{name: :text, text: "us-west-1"}]},
                                           %{name: :table_cell,
                                             children: [%{name: :text, text: "105"}]}]}]}]}]

Json
----

Generates a code block containing the pretty-printed JSON encoding of a
variable.

Examples
~~~~~~~~

With ``my_json`` equal to

.. code-block:: json

    {
      "foo": "bar",
      "stuff": {
        "hello": "world"
      }
    }

the template

::

  ~json var=$my_json~

would render the text

.. code-block:: json

    {
      "foo": "bar",
      "stuff": {
        "hello": "world"
      }
    }
