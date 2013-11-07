# &micro;phisher

## Introduction

&micro;phisher is a tool designed to support social engineering activities. It
automates the collecting and analysis of public social network data (the
current version only handles [Twitter](https://www.twitter.com "Twitter")), and
provides an interactive assisted text input interface which provides users
real time metrics on word usage, hashtag and user references, as well as word
suggestion based on usage frequency on the social network source.

&micro;phisher can also be used to validate suspect input against a known user
profile using the same metrics.

## Installation

&micro;phisher was developed using Ruby 1.9.3 and 2.0.0, both installed
through [RVM](https://rvm.io/ "Ruby Version Manager"), under OSX 10.6 and
10.7, as well as Ubuntu 13.04 and 13.10. Getting the correct Ruby version
running on your particular environment is beyond the scope of this document,
but the authors strongly advise the use of RVM installed as a regular user,
as it provides the easiest way to handle external dependencies and gems
without requiring administrative privileges on the system.

### rubygems

&micro;phisher is a Ruby on Rails application, and the installation of most
dependencies is handled by the `bundler` gem. but the application also relies
on `treat`, which requires a separate installation step to fetch additional
resources.

```
$ git clone https://github.com/urma/microphisher
$ gem install bundler
$ bundle update && bundle install
$ irb
irb> require 'treat'
irb> Treat::Core::Installer.install 'english'
```

Some users have reported issues while installing `rjb`, a gem used to allow
communication between `treat` and the Java code in
[OpenNLP](https://opennlp.apache.org/ "OpenNLP"). `rjb` requires a Java 6 JDK
or later, and the `JAVA_HOME` variable must be set appropriately *before*
running bundler. The `JAVA_HOME` must point to the root of the JDK installation
directory, under which a `include` directory should exist.

### External Dependencies

&micro;phisher uses [MongoDB](http://www.mongodb.org/ "MongoDB") for persistence,
which must be properly installed and configured before running the application
for the first time. There are no specific configuration requirements for it,
so standard distribution packages (for Linux systems),
[Macports](https://www.macports.org/ "Macports") or
[Homebrew](http://brew.sh/ "Homebrew") default installations should work out of
the box.

## Configuration

### Database

Database configuration resides in `config/mongoid.yml`, which is documented in
the [Mongoid site]
(http://mongoid.org/en/mongoid/docs/installation.html#configuration
"Mongoid documentation"). Unless the user tweaked the MongoDB configuration,
the default configuration file should work without any changes.

Since we are not using a relational database, there is no need to execute
a separate step to create tables and columns -- Mongoid will create those
as needed.

### OAuth

The OAuth configuration file, `config/oauth.yml`, requires the user to
register a new Twitter application at https://twitter.com/oauth_clients/new.
The parameter values will be provided by Twitter after the application is
registered. Please notice that the application *must have* a callback
URL configured (although its values is not used by &micro;phisher) -- this
is a restriction of the Twitter OAuth implementation when used as an
authentication service.

The `config/oauth.yml` also provides separate entries for development,
test and production environments. This allows the user to use separate
OAuth tokens for each scenario, as well as provide stub/mock REST API
implementations.

### delayed_job

[delayed_job](https://github.com/collectiveidea/delayed_job
"delayed_job") is a batch/background job scheduler used by
&micro;phisher to handle long-running activities, such as the NLP
parsing and fetching of status updates. Since it runs asynchronously
from the main web interface of the tool, it requires a separate
Ruby instance. This can be started by executing (copied directly
from the `delayed_job` documentation):

```
RAILS_ENV=production script/delayed_job start
RAILS_ENV=production script/delayed_job stop

# Runs two workers in separate processes.
RAILS_ENV=production script/delayed_job -n 2 start
RAILS_ENV=production script/delayed_job stop

# Set the --queue or --queues option to work from a particular queue.
RAILS_ENV=production script/delayed_job --queue=tracking start
RAILS_ENV=production script/delayed_job --queues=mailers,tasks start

# Runs all available jobs and then exits
RAILS_ENV=production script/delayed_job start --exit-on-complete
# or to run in the foreground
RAILS_ENV=production script/delayed_job run --exit-on-complete
```

*Important:* If `delayed_job` is not running then any attempts
to add new data sources or create user profiles will silently be
held in a suspended state until the job scheduler is started.

## Usage

If you arrived at this project then you probably saw our presentation at Black Hat 2013 and knows how it works
already, right? =)

## Copyright

microphisher - a spear phishing support tool

Created by [urma](https://github.com/urma) and [jespinhara](https://github.com/jespinhara)  
Copyright (C) 2013 [Trustwave Holdings, Inc.](https://www.trustwave.com/ "Trustwave")
 
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
  
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
