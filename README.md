# Clatter

web application like a twitter clone

[![Build Status](https://travis-ci.org/hyone/clatter.svg?branch=master)](https://travis-ci.org/hyone/clatter)
[![Coverage Status](https://coveralls.io/repos/hyone/clatter/badge.svg?branch=master)](https://coveralls.io/r/hyone/clatter?branch=master)
[![Code Climate](https://codeclimate.com/github/hyone/clatter/badges/gpa.svg)](https://codeclimate.com/github/hyone/clatter)

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Demo

https://clatter-demo.herokuapp.com

### demo user

    user: sample
    password: password

## Installation

### Requirement

- ImageMagick
- bower

### Manual deployment to heroku

```sh
$ git clone https://github.com/hyone/clatter.git
$ cd clatter

$ heroku login
$ heroku create <application-name>

# To use heroku-buildpack-multi
$ heroku config:add BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-multi.git

$ git remote add heroku https://git.heroku.com/<application-name>.git/
$ git push heroku master
$ heroku run rake db:migrate
```

### Using OAuth services to register and login a user

This application is able to use Twitter, Github and Google as OAuth authentication services.
To use these services,

At first, register the application to OAuth services we want to use:

These callback URLs must be set respectively like below:

- Twitter: ``${APP_ROOT_URL}/users/auth/twitter/callback``
- Github:  ``${APP_ROOT_URL}/users/auth/github/callback``
- Google:  ``${APP_ROOT_URL}/users/auth/google_oauth2/callback``

and then, set consumer key and consumer secret to *ENVIRONMENT VARIABLES* respectively like below:

Twitter:

    TWITTER_CONSUMER_KEY
    TWITTER_CONSUMER_SECRET

Github:

    GITHUB_CLIENT_ID
    GITHUB_CLIENT_SECRET

Google:

    GOOGLE_CLIENT_ID
    GOOGLE_CLIENT_SECRET

and then, restart server.

In case of heroku, set *ENVIRONMENT VARIABLES* like below:

```sh
$ heroku config:add TWITTER_CONSUMER_KEY=XXXXXXXXXXXXXXXXXXXXXXXXX
$ heroku config:add TWITTER_CONSUMER_SECRET=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
$ heroku restart
```

## Development

### Requirement on Development

In addition to packages required on installation:

- docker
- fig
- terminal-notifier (Optional)


### Setup demo data

```sh
# after set up database
$ bin/rake db:seed:development
```
