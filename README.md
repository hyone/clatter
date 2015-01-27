# TwitterApp

web application like a twitter clone

[![Build Status](https://travis-ci.org/hyone/twitter_app.svg?branch=master)](https://travis-ci.org/hyone/twitter_app)
[![Coverage Status](https://coveralls.io/repos/hyone/twitter_app/badge.svg?branch=master)](https://coveralls.io/r/hyone/twitter_app?branch=master)
[![Code Climate](https://codeclimate.com/github/hyone/twitter_app/badges/gpa.svg)](https://codeclimate.com/github/hyone/twitter_app)

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Demo

https://hyone-twitter-app.herokuapp.com

### demo user

    user: sample_user
    password: password

## Installation

### Requirement

- ImageMagick
- bower

### Manual deployment to heroku

```sh
$ git clone https://github.com/hyone/twitter_app.git
$ cd twitter_app

$ heroku login
$ heroku create <application-name>

# To use heroku-buildpack-multi
$ heroku config:add BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-multi.git

$ git remote add heroku https://git.heroku.com/<application-name>.git/
$ git push heroku master
$ heroku run rake db:migrate
```

### Using OAuth services to register and login a user

this application is able to use Twitter, Github and Google as oauth authentication services.
To use these services, set ENVIRONMENT VARIABLES below respectively:

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

In case of heroku, set ENVIRONMENT VARIABLES like below:

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
