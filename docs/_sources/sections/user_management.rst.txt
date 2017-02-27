User management
===============

If you’ve gone through the :doc:`installation_guide`, you might have
noticed that we had to create a Cog user before you could run any
commands. The reason we need a full user object and don’t just ask for a
Slack username is central to Cog’s design; we need users so Cog can
check permissions when running a command. And, continuing along those
lines, we also keep users and chat handles separate so changing your
Slack username or switching chat providers doesn’t force you to rework
any of your assigned groups or roles.

While this design allows Cog to implement permisisons and groups in a
sane way, it might be tedious to manage by hand, especially if you’re
trying to keep it in sync with another service that holds your
organization’s user data. So why not automate syncing your organizations
users with Cog users? Below I’ll walk you through three different ways
to automate user management: enabling self registration, writing a
script with cogctl, and using Cog’s API directly.

Self Registration
-----------------

The easiest way to avoid manually creating Cog users for each new member
of your team, is to enable "Self Registration" by setting the
environment variable ``COG_ALLOW_SELF_REGISTRATION=1``. Once enabled, if
Cog is contacted by a new user it does not know about, a user will
automatically be created for them with information populated from their
chat user and a randomly generated password. However, this new user will
have no permissions as it hasn’t been added to any groups yet. An admin
will have to manually assign them to a group to give them any
permissions. If you need more automation around setting specific user
details or want to also automatically assign them to specific groups,
writing a script around cogctl commands is the next best option.

User Management via Cogctl
--------------------------

You’ve probably already used cogctl to bootstrap Cog, but it has also
been designed for use in shell scripts. Let’s walk through a quick
example of importing users from a CSV file with a simple shell script.

First, let’s go over the cogctl commands we’ll be using.

| ``cogctl user create`` - Creates a Cog user
| ``cogctl chat-handle create`` - Creates a chat handle for a given
  user
| ``cogctl group add`` - Adds a user to a given group

Our CSV file will look like this:

**users.csv.**

.. code:: text

    email,password,slack_username,groups
    mark@operable.io,secr3t,imbriaco,"admin,raleigh"
    kevin@operable.io,passw0rd,kevsmith,"admin,raleigh"
    patrick@operable.io,k3yphrase,vanstee,"admin,atlanta"

We can pretty easily loop through each row, to create a user, add a chat
handle and add them them to the set of groups.

**import.sh.**

.. code:: shell

    #!/usr/bin/env bash

    OLDIFS=$IFS
    IFS=,

    cat $1 | tail +2 | while read email password username groups; do
      ./cogctl user create $username \
        --email $email \
        --password $password < /dev/null

      ./cogctl chat-handle create $username slack $username < /dev/null

      groups=$(echo "$groups" | sed -e 's/"//g')
      read -ra groups <<< "$groups"

      for group in "${groups[@]}"; do
        ./cogctl group add $group $username < /dev/null
      done
    done

    IFS=$OLDIFS

There are a few caveat though. cogctl reads from STDIN, so you’ll
noticed I’ve added ``< /dev/null`` to the end to avoid the while loop
from terminating after the first item. Also if you need to do any output
parsing it can be difficult since we emit structured text rather than
something easy to parse, like JSON. If you’re looking to do something
fancier, like an idempotent user sync based on email address,
interacting directly with the API is your best bet.

User Management via Cog’s API
-----------------------------

While we created cogctl as an easy way to complete simple tasks, you can
always use Cog’s HTTP API to handle more advanced work or cases where
it’s not convenient to shell out to cogctl. In fact, it’s the same API
used by cogctl, so the cogctl codebase can be a good place to start if
you want to do something similar to an existing command.

If you’ve dealt with a modern HTTP API you’ll find Cog’s API to be
pretty common. It (mostly) uses Restful URIs, it accepts and responds
with JSON, and uses an Authorization header containing a token to
authenticate a specific user. Here’s a quick example in Ruby similar to
the one above that will handle cases like changing your username and
removing someone from a group as well.

**sync.rb.**

.. code:: Ruby

    #!/usr/bin/env ruby

    require 'csv'
    require 'httparty'
    require 'json'

    $username = ENV['COG_USERNAME']
    $password = ENV['COG_PASSWORD']
    $host     = ENV['COG_HOST']
    $port     = ENV['COG_PORT']
    $secure   = ENV['COG_HTTPS'] == '1'
    $address = "#{$secure ? 'https' : 'http'}://#{$host}:#{$port}"

    def create_token
      params = {username: $username, password: $password}
      response = HTTParty.post("#{$address}/v1/token", body: params)
      response.parsed_response["token"]["value"]
    end

    def find_user(email)
      headers = {"Authorization" => "token #{create_token}"}
      response = HTTParty.get("#{$address}/v1/users", headers: headers)
      users = response.parsed_response["users"]
      users.find { |u| u["email_address"] == email }
    end

    def create_user(user)
      headers = {"Authorization" => "token #{create_token}"}
      params = {user: user}
      response = HTTParty.post("#{$address}/v1/users", headers: headers, body: params)
      user = response.parsed_response["user"]
      puts "Created user #{user["email_address"]}"
      user
    end

    def update_user(user_id, username, password)
      headers = {"Authorization" => "token #{create_token}"}
      params = {user: {user_id: user_id, username: username, password: password}}
      response = HTTParty.patch("#{$address}/v1/users/#{user_id}", headers: headers, body: params)
      user = response.parsed_response["user"]
      puts "Updated user #{user["email_address"]}"
      user
    end

    def find_group(name)
      headers = {"Authorization" => "token #{create_token}"}
      response = HTTParty.get("#{$address}/v1/groups", headers: headers)
      groups = response.parsed_response["groups"]
      groups.find { |g| g["name"] == name }
    end

    def update_chat_handle(user, username)
      headers = {"Authorization" => "token #{create_token}"}
      params = {chat_handle: username}
      response = HTTParty.post("#{$address}/v1/users/#{user["id"]}/chat_handles", headers: headers, body: params)
      chat_handle = response.parsed_response["chat_handle"]
      puts "Updated chat handle for user #{user["email_address"]}"
      chat_handle
    end

    def manage_group(user, group_id, action)
      headers = {"Authorization" => "token #{create_token}"}
      params = {users: {action => [user["username"]]}}
      response = HTTParty.post("#{$address}/v1/groups/#{group_id}/users", headers: headers, body: params)
      group = response.parsed_response["group"]
      adding = action == :add
      puts "#{adding ? "Added" : "Removed"} user #{user["email_address"]} #{adding ? "to" : "from"} group #{group_id}"
      group
    end

    CSV.foreach(ARGV.first, headers: true) do |csv_user|
      if cog_user = find_user(csv_user["email_address"])
        update_user(cog_user["id"], csv_user["username"], csv_user["password"])
      else
        cog_user = create_user(csv_user)
      end

      update_chat_handle(cog_user, csv_user["username"])

      csv_groups = csv_user["groups"].split(",").map { |g| find_group(g) }.map { |g| g["id"] }
      cog_groups = cog_user["groups"].map { |g| g["id"] }

      groups_to_add    = csv_groups - cog_groups
      groups_to_remove = cog_groups - csv_groups

      groups_to_add.each { |g| manage_group(cog_user, g, :add) }
      groups_to_remove.each { |g| manage_group(cog_user, g, :remove) }
    end
