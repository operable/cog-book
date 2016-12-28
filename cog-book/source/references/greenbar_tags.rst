Greenbar Tags
=============

if
--

Provides a small set of operators to express conditional logic.
Conditionally evaluates its body based on the value of the ``cond``
attribute.

Example
~~~~~~~

\`\`\` :sub:`if cond=$doit bound?` Hello there! :sub:`end` \`\`\`

Given the variable ``$doit`` is bound, the above template would produce:

\`\`\` Hello there! \`\`\`

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

\`\`\` :sub:`each var=$users` First Name: :sub:`$item.first\_name` Last
Name: :sub:`$item.last\_name` :sub:`end` \`\`\`

Customizing the body variable:

\`\`\` :sub:`each var=$users as=user` First Name:
:sub:`$user.first\_name` Last Name: :sub:`$user.last\_name` :sub:`end`
\`\`\`

Given the variable ``$users`` is bound to
``[%{"first_name" => "John", "last_name"
=> "Doe"}]`` then both of the above templates would produce:

\`\`\` First Name: John Last Name: Doe \`\`\`

Join
----

Iterates over a list, joining the rendered items with the value of the
``with`` attribute, which defaults to ``", "``. Similar to the ``each``
tag, you may also provide an ``as`` attribute which sets the name of the
variable scoped to the body of the tag.

Examples
~~~~~~~~

Create a comma-delimited list

\`\`\` :sub:`join var=$names`\ ~$item\ :sub:`~end` \`\`\`

Given that the variable ``$names`` is bound to
``["Mark", "Kevin", "Shelton"]`` then the above template would produce:

\`\`\` Mark, Kevin, Shelton \`\`\`

Specify a custom joiner

\`\`\` :sub:`join var=$names with="-"`\ ~$item\ :sub:`~end` \`\`\`

Custom binding

\`\`\` :sub:`join var=$names as=name`\ ~$name\ :sub:`~end` \`\`\`

Bodies can contain arbitrary instructions

\`\`\` :sub:`join var=$users`\ ~$item.profile.username\ :sub:`~end`
\`\`\`

Count
-----

Returns the size of the referenced variable. When referencing lists the
size is the length of the list. For maps, size is the number of the
map’s unique keys. Any other value type will display "N/A".

Examples
~~~~~~~~

\`\`\` There are :sub:`count var=$users` users. \`\`\`

Given that the variable ``$users`` is bound to
``[{ "name": "Mark" }, { "name":
"Kevin" }]`` then the above template would produce:

\`\`\` There are 2 users. \`\`\`

Given that the variable ``$users`` is bound to
``{ "imbriaco": 1, "kevsmith": 2,
"shelton": 3 }`` then the above template would produce:

\`\`\` There are 3 users. \`\`\`

Break
-----

Inserts a hard newline into the rendered template. This can be useful to
work around situtions where Markdown consolidates newlines.

Examples
~~~~~~~~

Normally Markdown will combine two code blocks into one if they are
separated by a single newline.

\`\`\` ``This is a line of code`` ``This is another line of code``
\`\`\`

will render as ``This a line of codeThis is another line of code``

\`\`\` ``This is a line of code`` :sub:`br`
``This is another line of code`` \`\`\`

will render as

\`\`\` This is a line of code This is another line of code \`\`\`

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

\`\`\` { "title": <attribute\_name>, "value": <attribute\_value>,
"short": false } \`\`\`

Examples
~~~~~~~~

The template

\`\`\` :sub:`attachment title="VM Use By Region" runtime=$timestamp`
\|Region\|Count\| \|---\|---\| :sub:`each var=$regions as=region`
\|\ :sub:`$region.name`\ \|\ :sub:`$region.vm\_count`\ \| :sub:`end`
:sub:`end` \`\`\`

when executed with the data

\`\`\` %{"timestamp" ⇒ "Mon Sep 12 13:06:57 EDT 2016", "regions" ⇒
[%{"name" ⇒ "us-east-1", "vm\_count" ⇒ 113}, %{"name" ⇒ "us-west-1",
"vm\_count" ⇒ 105}]} \`\`\`

generates the rendering directives

\`\`\` [%{name: :attachment, title: "VM Use By Region", fields:
[%{short: false, title: "runtime", value: "Mon Sep 12 13:06:57 EDT
2016"}], children: [%{name: :table, children: [%{name: :table\_header,
children: [%{name: :table\_cell, %{name: :table\_cell, %{name:
:table\_row, children: [%{name: :table\_cell, %{name: :table\_cell,
%{name: :table\_row, children: [%{name: :table\_cell, %{name:
:table\_cell, \`\`\`

Json
----

Generates a code block containing the pretty-printed JSON encoding of a
variable.

Examples
~~~~~~~~

With ``my_json`` equal to

\`\`\` { "foo": "bar", "stuff": { "hello": "world" } } \`\`\`

the template

\`\`\` :sub:`json var=$my\_json` \`\`\`

would render the text

\`\`\` { "foo": "bar", "stuff": { "hello": "world" } } \`\`\`
