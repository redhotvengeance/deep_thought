# DeepThought

Deploy smart, not hard.  
<br/>

---

**
**Deep Thought is still in the initial hacking phase, and has not yet hit a release point.**
**

---

## See

Deep Thought takes all of the thought out of deploying.

Want to prevent deployment conflicts? Deep Thought does that. Want to deploy with Hubot? Deep Thought has you covered. Looking to ensure a build is green before it is deployed? Deep Thought yawns at your puny requests. Want a web interface? Got it. How about an API? Yep. Security? Totally locked down. Deep Thought has your deployments covered.

Deep Thought was inspired by GitHub's own Hubot+Heaven workflow. Check out [Zach Holman's talk](http://zachholman.com/talk/unsucking-your-teams-development-environment/) to see the original inspiration.

## Want

    git clone https://gist.github.com/redhotvengeance/5746731

## Use

### Setup

Deep Thought is designed to be deployed to Heroku:

    heroku apps:create [NAME]
    heroku config:set RACK_ENV=production

Deep Thought will, by default, route all requests through https for security. It is *strongly* recommended to set a secret token to be used for session cookies:

    uuid=`UUIDGEN`
    secret=$(echo -ne "\0$uuid" | base64 | sed -e "s/=//g")
    heroku config:set SESSION_SECRET="$secret"

Deep Thought requires a PostgreSQL database. Add one to your Heroku app:

    heroku addons:add heroku-postgresql:dev

Now go ahead and push Deep Thought to Heroku:

    git push heroku master

To start using Deep Thought, you'll need to create an initial user. Fortunately, Deep Thought makes this easy to do:

    heroku run rake create_user[user@email.com,secretpassword]

Now head over to your Deep Thought instance and login:

    open https://<app-name>.herokuapp.com

Deep Thought requires the use of a background worker for deployments. Normally, on Heroku, this would become costly, as it would require spinning up a second (worker) dyno. However, Deep Thought includes the ability to intelligently spin this dyno up and down to help minimize (or even eliminate) costs. To enable this functionality, two environment variables need to be set:

    HEROKU_APP=<app-name>
    HEROKU_API_KEY=<your-heroku-api-key>

### Add a project

Once logged in, click the `+ add project` button on the `projects` page. Enter a unique project name, the remote Git repository url for the project, and the project type (i.e. "capistrano"). If your project uses continuous integration, set it to `true` (more on that later). Click `create project`, and now your project is set up and ready to deploy.

By default, Deep Thought supports deploying projects with [Capistrano](https://github.com/capistrano/capistrano). Deep Thought expects to find a `Capfile` in all projects set as the "capistrano" type. It automatically calls tasks under the "deploy" namespace.

Make sure to add any dependencies needed to deploy your project to your Gemfile, such as:

    gem "capistrano"
    gem "railsless-deploy"

### Add a key

It is likely that your project repos are private, and even if they are not, you still probably need to authenticate via ssh key to access servers for deployment. If you need to add a ssh key to Deep Thought, then you can use the Deep Thought Heroku buildpack:

    heroku config:set BUILDPACK_URL=https://github.com/redhotvengeance/heroku-buildpack-deep-thought
    ssh_key=`cat ~/.ssh/your_ssh_key`
    heroku config:set SSH_KEY="$ssh_key"
    heroku config:set SSH_HOST=github.com

Keep in mind that the ssh key shouldn't have a password - otherwise Deep Thought won't be able to use it!

### Deploy

Click on a project from the homepage. Select the branch to deploy, and optionally define additional parameters:

- `environment`: Sets the environment to deploy to (for instance, if using the [Capistrano multistage extension](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension)).
- `box`: Sets a specific server to deploy to (passed to Capistrano as a variable `cap deploy -s box=prod`).
- `action`: Sets a subtask to deploy (for instance, if "config" is added, then Capistrano would call `cap deploy:config`).
- `variable`: Sets additional values that can be passed to the deploy (for instance, if set to `force=true`, Capistrano would call `cap deploy -s force=true`).

Click `deploy` - now a deployment is underway!

Deep Thought will let you know once the deployment is finished. If you'd like to see a log of previous deployments, click the `history` button. Clicking on a subsequent deployment will show you the details of that deployment.

### Continuous integration

If you use continuous integration, you can have Deep Thought check to make sure a build is green before deploying. By default, Heroku supports interfacing with [Janky](https://github.com/github/janky).

To enable continuous integration, several environment variables must be set:

    heroku config:set CI_SERVICE=janky
    heroku config:set CI_SERVICE_ENDPOINT=http://your-janky-server.com
    heroku config:set CI_SERVICE_USERNAME=janky_username
    heroku config:set CI_SERVICE_PASSWORD=janky_password

Now, so long as a project has `uses continuous integration` set to true, Deep Thought will check the project/branch build status before deploying. Note that the project name in Deep Thought *must* match the project name in your CI server.

### API

To use the API, you must have an API key. To generate a key, go to the `me` page and click `generate new api key`.

All API requests must have the `Accept` header set to `application/json`. To authenticate, the `Authorization` header should be set to `Token token="<your api key>"`.

The current API routes are:

- `GET /deploy/status` - Get the current status of Deep Thought.
- `POST /deploy/:app` - Deploy a project. Optionally pass (JSON encoded) `environment`, `box`, `actions` (array), `variables` (key/value object), and `on_behalf_of` (username requesting deploy - useful for bots).
- `POST /deploy/setup/:app` - Setup a new project. Required to include (JSON encoded) `repo_url` and `deploy_type`. Optionally pass (JSON encoded) `ci` (boolean).

### Hubot

Hubot integrates wonderfully with Deep Thought. He communicates via the API, which means he'll need an account with an API generated.

Once you've setup the Hubot user and have its API key, grab the Deep Thought Hubot script and add it to your Hubot.

Set the following config variables for your Hubot:

    heroku config:set DEEP_THOUGHT_URL=https://your-deep-thought.herokuapp.com
    heroku config:set DEEP_THOUGHT_TOKEN=<hubot api key>

Finally, Deep Thought likes to talk back to Hubot to let him know how deploys are going. Login to the Hubot account on Deep Thought, head to the `me` page, and set the `notification url` to `http://your.hubot.com/notify`.

To learn more about how to ask Hubot to deploy, check out the Hubot script.

## Enjoy

Feel that? Yep - that's your stresses melting away. Look at all this time you have now! Maybe you'll make a sandwich. Or watch a documentary. Perhaps start a cute herb garden.

## Hack

Want to hack on Deep Thought?

Set it up:

    script/bootstrap

Create an `.env`:

    echo RACK_ENV=development > .env

Set up the databases (PostgreSQL):

    createuser deep_thought
    createdb -O deep_thought -E utf8 deep_thought_development
    createdb -O deep_thought -E utf8 deep_thought_test
    rake db:migrate

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
