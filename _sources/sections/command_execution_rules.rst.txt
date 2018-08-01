Command Execution Rules
=======================

Rule Structure
--------------

Rules help Cog to determine who is able to perform what task. Cog rules
follow a specific format. The rule structure describes what command is
executed and what permission is needed in order to execute the command.
All rules begin with the phrase ``when command is``. If a user
does not have the specified permission, the user is not able to execute
the command.

Do you have an entire group of people who should have a certain command?
No problem, set up the group and assign the permission to that group.
Cog will still recognize that each user has the correct permissions
according to the group.

.. code:: shell

    when command is <bundle_name>:<command_name> must have <bundle_name|site>:<permission_name>

Arguments and Options Qualifiers
--------------------------------

You may also set rules to cover very specific invocations of a certain
command. You can set option and arg values to match for particular
command executions.

The argument and option portion of the rules begin with the word
```with```. There are argument and option qualifiers used in
this phrasing. The possible key words and phrases that Cog recognizes
and acts upon when using the argument and option qualifier phrase are as
follows:

-  and

-  or

-  <,>, ==, !=

-  any in

-  all in

-  in

.. code:: shell

    when command is <bundle_name>:<command_name> with arg[<position>] == '<some value>' must have <bundle_name|site>:<permission_name>

or

.. code:: shell

    when command is <bundle_name>:<command_name> with option[<some option>] == <some value> must have <bundle_name|site>:<permission_name>

or

.. code:: shell

    when command is <bundle_name>:<command_name> with <any|all> <args|options> in ['list', 'of', 'values'] must have <bundle_name|site>:<permission_name>

You may combine these qualifiers such that your rules can be as simple
or as complicated as you need them to be.

The following are rule examples with valid argument and option qualifiers:

| "when command is foo:bar with option[delete] == true must have foo:destroy"
| "when command is foo:set with option[set] == /.\*/ must have foo:baz-set"
| "when command is foo:qux with arg[0] == \'status\' must have foo:view"
| "when command is foo:barqux with option[delete] == true and arg[0] > 5 must have foo:destroy"
| "when command is foo:bar with any args in ['wubba'] must have foo:read"
| "when command is foo:bar with any args in ['wubba', /^f.*/, 10] must have foo:read"
| "when command is foo:bar with all arg in [10, 'baz', 'wubba'] must have foo:read"
| "when command is foo:bar with arg[0] in ['baz', false, 100] must have foo:read"
| "when command is foo:bar with any option == /^prod.*/ must have foo:read"
| "when command is foo:bar with all option < 10 must have foo:read"
| "when command is foo:bar with all options in ['staging', 'list'] must have foo:read"
| "when command is foo:bar with option[foo] in ["foo", "bar"] allow"

You may also use the an 'in' expression when referencing values in a list option.

| "when command is foo:bar with option[list] in ["foo", "bar"] allow
| "when command is foo:bar with option[list] in [/foo/] allow

Permissions
-----------

Every rule must state what permissions are necessary in order to execute
a certain command. The beginning of the permissions portion of the rule
is indicated by the phrase ``must have``. This is where you
state any and all permissions that are deemed necessary in order to
execute a particular command. It is possible to only require a single
permission, a certain combination, or a list of permissions. The
following are the possible keywords used when declaring permissions:

-  or

-  and

-  any in

-  all in

-  allow

For example, the following are rule examples with valid permission settings:

| "when command is foo:baz must have foo:write and site:admin"
| "when command is foo:export must have all in [foo:write, site:ops] or any in [site:admin, site:management]"
| "when command is foo:bar must have any in [foo:read, foo:write]"
| "when command is foo:qux must have all in [foo:write, site:ops] and any in [site:admin, site:management]"
| "when command is foo:biz allow"
|

.. note:: Note the special ``allow`` keyword. ``allow`` may not be
  accompanied with any other keyword or phrase. Commands
  using this permission are allowed to be executed by any registered
  user in Cog.

Site Namespace
--------------

The ``site`` namespace is used when trying to set permissions for a
user, group, or role. This does **not** have to be command specific. You
may use site permissions when deciding what group should have
permissions to execute certain commands, in specific environments,
within certain groups.

A user can only create and delete permissions from the site namespace.
You cannot delete the permissions that are part of a command bundle.

For example, let’s say your organization has an IT group, "it", an
engineering group, "eng", and a QA group, "qa". As a result, you have 3
different environments "prod", "test" and "stage". There are certain
tasks that can be performed in each environment, but you must belong to
the correct group and be operating in the correct environment.

So we will assume that The IT group operates in "prod", QA in "qa", and
Engineering in "staging", though IT should be able to handle certain
tasks in all environments such as patch updates and the sort.

Let’s create some example commands: foo:deploy, foo:patch, foo:delete,
foo:readlog

For the examples sake, we’ll have the example permissions map to these
commands such that they may look like: foo:p_deploy, foo:p_patch,
foo:p_delete, foo:p_readlog

We’ll set up site permissions based on each group and each environment:
site:prod, site:test, site:stage, site:it, site:qa, site:eng

Some resulting rules may look like the following:

| "when command is foo:deploy when option[environment] == \'prod\' must
  have all in [site:it, site:prod, foo:p_deploy]"
| "when command is foo:deploy when option[environment] == \'qa\' must have
  site:test and foo:p_deploy"
| "when command is foo:deploy when option[environment] == \'stage\' must
  have site:stage and foo:p_deploy"
| "when command is foo:patch must have all in [foo:p_patch, site:it] or
  all in [site:qa, site:test, foo:p_patch] or all in [site:eng,
  site:stage, foo:p_patch]"
