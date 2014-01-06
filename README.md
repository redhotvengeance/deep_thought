# Deep Thought

[![Build Status](https://travis-ci.org/redhotvengeance/deep_thought.png?branch=master)](https://travis-ci.org/redhotvengeance/deep_thought)

Deploy smart, not hard.

## See

Deep Thought takes all of the thought out of deploying.

Want to prevent deployment conflicts? Deep Thought does that. Want to deploy with Hubot? Deep Thought has you covered. Looking to ensure a build is green before it is deployed? Deep Thought yawns at your puny requests. How about deployment locking? Of course! Want a web interface? Got it. An API? Yep. Security? Totally locked down. Deep Thought is master of your deployments.

Deep Thought was inspired by GitHub's own Hubot+Heaven workflow. Check out [Zach Holman's talk](http://zachholman.com/talk/unsucking-your-teams-development-environment/) to see the original inspiration.

## Want

Use [this Gist](https://gist.github.com/redhotvengeance/5746731) to get started:

    git clone git://gist.github.com/5746731 deep_thought

## Use

### Setup

Deep Thought needs an environment with Ruby and Git installed, and also access to a database. Deep Thought by default expects a PostgreSQL database, but should work with any ActiveRecord-compatible database.

Deep Thought will work fine on any server or VM matching those requirements, though it is largely designed to be deployed to Heroku:

    heroku apps:create [NAME]
    heroku config:set RACK_ENV=production

Deep Thought will, by default, route all requests through https for security. It is *strongly* recommended to set a secret token to be used for session cookies:

    uuid=`UUIDGEN`
    secret=$(echo -ne "\0$uuid" | base64 | sed -e "s/=//g")
    heroku config:set SESSION_SECRET="$secret"

Deep Thought requires a PostgreSQL database. Add one to your Heroku app:

    heroku addons:add heroku-postgresql

Now go ahead and push Deep Thought to Heroku:

    git push heroku master

To start using Deep Thought, you'll need to create an initial user. Fortunately, Deep Thought makes this easy to do:

    heroku run rake create_user[user@email.com,secretpassword]

Now head over to your Deep Thought instance and login:

    open https://<app-name>.herokuapp.com

Deep Thought requires the use of a background worker for deployments. Normally, on Heroku, this could become costly, as it would require spinning up a second (worker) dyno. However, Deep Thought includes the ability to intelligently spin this dyno up and down to help minimize (or even eliminate) costs. To enable this functionality, two environment variables need to be set:

    HEROKU_APP=<app-name>
    HEROKU_API_KEY=<your-heroku-api-key>

If you'd like to use a database other than PostgreSQL, you'll need to add appropriate gem to your Gemfile and set the `DATABASE_ADAPTER` environment variable. For instance, if you'd like to use MySQL, add the gem to the Gemfile:

    gem "mysql2"

Then set the adapter environment variable:

    DATABASE_ADAPTER=mysql2

### Add a project

Once logged in, click the `+ add project` button on the `projects` page. Enter a unique project name and the remote Git repository url for the project. Click `create project`, and your project will be set up and ready to deploy.

### Deploy

Click on a project from the homepage. Select the branch to deploy, and optionally define additional parameters:

- `environment`: Sets the environment to deploy to (`development`, `staging`, `production`, etc - defaults to `development`)
- `box`: Sets a specific server to deploy to (passed as an argument to the shell script - `script/deploy development deploy box=prod`)
- `action`: Sets a subtask to deploy (for instance, if "config" is added, then Deep Thought would execute `script/deploy development deploy:config`)
- `variable`: Sets additional values that can be passed to the deploy (for instance, if set to `force=true`, Deep Thought would execute `script/deploy development deploy force=true`)

Click `deploy` - now a deployment is underway!

Deep Thought will let you know once the deployment is finished. If you'd like to see a log of previous deployments, click the `history` button. Clicking on a subsequent deployment will show you the details of that deployment.

### .deepthought.yml

Deep Thought expects to find a `.deepthought.yml` file in the root of all projects. This file serves as a config for the project - it tells Deep Thought the information it needs to know to deploy the project.

Here's an example `.deepthought.yml`:

    deploy_type: shell
    ci:
      enabled: true
      name: project-name
    root: script/deploy

Let's break that down. The first line specifies the key name for the deployer this project will use (defaults to `shell`).

Lines 2-4 specify the continuous integration settings. `enabled` tells Deep Thought to check the CI server for green builds. `name` is the name of the project on the CI server.

Lines 1-4 are common to all projects, but additional data can be added to the config to supply information to a specific deployer. In this case, line 5 tells the shell deployer where to find the shell script it will execute (which defaults to `script/deploy`).

In addition to the `.deepthought.yml` file, make sure to add any dependencies needed to deploy your project to the project's Gemfile.

### Add a key

Your project repos may be private, and even if they are not, you still probably need to authenticate via ssh key to access servers for deployment. If you need to add an ssh key to a Deep Thought hosted on Heroku, then you can use the [Deep Thought buildpack](https://github.com/redhotvengeance/heroku-buildpack-deep-thought):

    heroku config:set BUILDPACK_URL=https://github.com/redhotvengeance/heroku-buildpack-deep-thought.git
    ssh_key=`cat ~/.ssh/your_ssh_key`
    heroku config:set SSH_KEY="$ssh_key"
    heroku config:set SSH_HOST=github.com

Keep in mind that the ssh key shouldn't have a password - otherwise Deep Thought won't be able to use it!

### Continuous integration

If you use continuous integration, you can have Deep Thought check to make sure a build is green before deploying. By default, Deep Thought supports interfacing with [Janky](https://github.com/github/janky).

To enable continuous integration, several environment variables must be set:

    heroku config:set CI_SERVICE=janky
    heroku config:set CI_SERVICE_ENDPOINT=http://your-janky-server.com
    heroku config:set CI_SERVICE_USERNAME=janky_username
    heroku config:set CI_SERVICE_PASSWORD=janky_password

Now, so long as a project enables continuous integration in its `.deepthought.yml` file, Deep Thought will check the project/branch build status before deploying.

### API

To use the API, you must have an API key. To generate a key, go to the `me` page and click `generate new api key`.

All API requests must have the `Accept` header set to `application/json`. To authenticate, the `Authorization` header should be set to `Token token="<your api key>"`.

The current API routes are:

- `GET /deploy/status` - Get the current status of Deep Thought.
- `POST /deploy/:app` - Deploy a project. Optionally pass (JSON encoded) `environment`, `box`, `actions` (array), `variables` (key/value object), and `on_behalf_of` (username requesting deploy - useful for bots).
- `POST /deploy/setup/:app` - Setup a new project. Required to include (JSON encoded) `repo_url`.

### Hubot

Hubot integrates wonderfully with Deep Thought. He communicates via the API, which means he'll need an account with an API generated.

Once you've setup the Hubot user and have its API key, grab the [Deep Thought Hubot script](https://github.com/redhotvengeance/hubot-scripts/blob/add-deep-thought/src/scripts/deep-thought.coffee) and add it to your Hubot.

Set the following config variables for your Hubot:

    heroku config:set HUBOT_DEEP_THOUGHT_URL=https://your-deep-thought.herokuapp.com
    heroku config:set HUBOT_DEEP_THOUGHT_TOKEN=<hubot api key>

Finally, Deep Thought likes to talk back to Hubot to let him know how deploys have gone. Login to the Hubot account on Deep Thought, head to the `me` page, and set the `notification url` to `http://your.hubot.com/deep-thought/notify/:room_name`, where `:room_name` is the name of the chat room you'd like Hubot to post in.

To learn more about how to ask Hubot to deploy, check out the [Hubot script](https://github.com/redhotvengeance/hubot-scripts/blob/add-deep-thought/src/scripts/deep-thought.coffee).

## Plugins

Deep Thought is architected on a plugin-based system, making it extendable with new deployers and CI service integrations. To see currently available plugins, check out the list of [deployers](https://github.com/redhotvengeance/deep_thought/wiki/Deployers) and [CI services](https://github.com/redhotvengeance/deep_thought/wiki/CI-Services) found in the [wiki](https://github.com/redhotvengeance/deep_thought/wiki).

### Deployers

Looking to make a new deployer? Excellent!

Your custom deployer should live in the `DeepThought::Deployer` namespace. Deep Thought deployers have two required methods: `setup?(project, config)` and `execute?(deploy, config)`. Both are predicate methods, and should return only truthy or falsy values. Your deployer should extend [`DeepThought::Deployer::Deployer`](https://github.com/redhotvengeance/deep_thought/blob/master/lib/deep_thought/deployer/deployer.rb), so it will inherit both of these methods - from there you can overwrite them with custom functionality as needed.

#### `setup?(project, config)`

The `setup?` method is called before deploys to ensure the project is setup as needed for the deploy to execute properly. For instance, if your deployer deploys by pushing to a Git remote, you can ensure that the Git remotes exist within `setup?`. Your deployer may have no need of `setup?`, in which case just don't bother overwriting the method.

A reference to the project is passed to the `setup?` method, as is the project config (which is the hash generated from the project's `.deepthought.yml` file). You can use access to the config to take advantage of any deployer-specific data that may have been put into the `.deepthought.yml` file.

The `setup?` method should return `true` when successful and `false` when not.

#### `execute?(deploy, config)`

The `execute?` method is where deployment happens.

This method should start the deploy and return once the deployment is finished. You also have access to the project config in this method, just in case any data from `.deepthought.yml` is necessary for deploying.

Once the deployment is complete, the output log from the deployment should be stored in `deploy.log`.

The `execute?` method should return `true` if the deploy was successful and `false` if it was not.

#### Register

You will also have to register your deployer with Deep Thought. When you register your deployer, you'll specify a key name and the deployer class. The key name is the same key used to set the `deploy_type` in `.deepthought.yml`.

Here is an example of how to register a deployer with Deep Thought:

    DeepThought::Deployer.register_adapter('key', DeepThought::Deployer::CustomDeployer)

Make sure to add your new deployer to the [list of plugins](https://github.com/redhotvengeance/deep_thought/wiki/Deployers) so others can find it and benefit from your contributions!

### CI Services

Looking to make a new CI service integration? Fantastic!

Your custom CI service should live in the `DeepThought::CIService` namespace. Deep Thought CI service integrations have two required methods: `setup?(settings)` and `is_branch_green?(app, branch, hash)`. Both are predicate methods, and should return only truthy or falsy values. Your CI service should extend [`DeepThought::CIService::CIService`](https://github.com/redhotvengeance/deep_thought/tree/master/lib/deep_thought/ci_service/ci_service.rb), so it will inherit both of these methods - from there you can overwrite them with custom functionality as needed.

#### `setup?(settings)`

The `setup?` method is called upon application start, and ensures the CI service is properly setup for use during the application lifetime.

The application environment is passed to the method via the `settings` argument. The abstract method already sets three instance variables from the environment:

- `@endpoint` - Set from `ENV['CI_SERVICE_ENDPOINT'], and specifies the URI to the CI service being pinged
- `@username` - Set from `ENV['CI_SERVICE_USERNAME'], and specifies the username used for authentication with the CI service
- `@password` - Set from `ENV['CI_SERVICE_PASSWORD'], and specifies the username used for authentication with the CI service

It is likely you will not have to overwrite this method since it already sets these common variables.

The `setup?` method should return `true` when successful and `false` when not.

#### `is_branch_green?(app, branch, hash)`

The `is_branch_green?` method is where build status checking happens.

This method should ensure that for the app/branch/commit hash being deployed, the CI server has done a successful build.

The `is_branch_green?` method should return `true` if the build was reported successful and `false` if it was not.

#### Register

You will also have to register your CI service with Deep Thought. When you register your CI service, you'll specify a key name and the CI service class. The key name is the same key used to set the `CI_SERVICE` environment variable.

Here is an example of how to register a CI service with Deep Thought:

    DeepThought::CIService.register_adapter('key', DeepThought::CIService::CustomCIService)

Make sure to add your new CI service to the [list of plugins](https://github.com/redhotvengeance/deep_thought/wiki/CI-Services) so others can find it and benefit from your contributions!

## Enjoy

Feel that? Yep - that's your stresses melting away. Look at all this time you have now! Maybe you'll make a sandwich. Or watch a documentary. Perhaps start a cute herb garden.

## Hack

Want to hack on Deep Thought?

Set it up:

    script/bootstrap

The bootstrap script will create an `.env`, install all required gems, set up the databases, and make a user. Of course, you can always do it manually.

Create an `.env`:

    echo RACK_ENV=development > .env

Install required gems:

    bundle install --binstubs

Set up the databases (PostgreSQL):

    createuser deep_thought
    createdb -O deep_thought -E utf8 deep_thought_development
    createdb -O deep_thought -E utf8 deep_thought_test
    rake db:migrate
    rake db:migrate RACK_ENV=test

Make a user:

    bundle exec rake create_user[test@test.com,secret]

Start the server:

    script/server

Open it:

    open http://localhost:4242

Test it:

    script/test

## Give

Want to make Deep Thought even deeper and more thoughtier? Contribute!

1. Fork
2. Create
3. Code
4. Test
5. Push
6. Submit
7. Yay!
