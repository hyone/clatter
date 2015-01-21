# TwitterApp

web application like a twitter clone

[![Build Status](https://travis-ci.org/hyone/twitter_app.svg?branch=master)](https://travis-ci.org/hyone/twitter_app)

## Demo

https://hyone-twitter-app.herokuapp.com

### demo user

    user: sample_user
    password: password

## Requirement

- ImageMagick
- bower

## Requirement on Development

In addition to packages above:

- docker
- fig
- terminal-notifier (Optional)


## Installation

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

this application is able to use Twitter, Github, Google as oauth authentication services.
To use these services, set ENVIROMENT VARIABLES below respectively:

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

### Setup demo data

```sh
# after set up database ( bin/rake db:migrate )
$ bin/rake db:seed:development
```
