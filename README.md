# &micro;phisher

## Introduction

&micro;phisher is a tool designed to support social engineering activities. It automates the collecting and analysis of
public social network data (the current version only handles Twitter), and provides an interactive assisted text
input interface which provides users real time metrics on word usage, hashtag and user references, as well as word
suggestion based on usage frequency on the social network source.

&micro;phisher can also be used to validate suspect input against a known user profile using the same metrics.

## Installation

&micro;phisher is a Ruby on Rails application, and uses MongoDB for data storage. The installation of most dependencies
is handled by the `bundler` gem, but the application also relies on `treat`, which requires a separate installation
step to fetch additional resources.

```
$ git clone https://github.com/urma/microphisher
$ gem install bundler
$ bundle update && bundle install
$ irb
irb> require 'treat'
irb> Treat::Core::Installer.install 'english'
```

After that, the user should configure the `config/mongoid.yml` and `config/oauth.yml`. The Mongoid configuration
file contains documentation on all the required parameters, while the OAuth configuration file requires the user
to register a new Twitter application at https://twitter.com/oauth_clients/new. The parameter values will be
provided by Twitter after the application is registered. Please notice that the application *must have* a callback
URL configured (although its values is not used by &micro;phisher) -- this is a restriction of the Twitter OAuth
implementation when used as an authentication service.

## Usage

If you arrived at this project then you probably saw our presentation at Black Hat 2013 and knows how it works
already, right? =)
