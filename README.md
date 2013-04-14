# DeepThought

Deploy smart, not hard.

## Installation

Add this line to your application's Gemfile:

    gem 'deep_thought'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install deep_thought

## Usage

TODO: Write usage instructions here

## Hacking

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
