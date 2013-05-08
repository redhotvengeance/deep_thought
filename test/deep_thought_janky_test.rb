require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtJankyTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    @janky = DeepThought::CIService::Janky.new
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_janky_setup_success
    @janky.setup({"CI_SERVICE_ENDPOINT" => "endpoint", "CI_SERVICE_USERNAME" => "username", "CI_SERVICE_PASSWORD" => "password"})

    assert @janky.endpoint == 'endpoint'
    assert @janky.username == 'username'
    assert @janky.password == 'password'
  end

  def test_janky_is_branch_green_success
    json = stub(:body => '[{"sha1":"hash","green":true}]')
    HTTParty.expects(:get).with("#{@janky.endpoint}/_hubot/app/branch", {:basic_auth => {:username => @janky.username, :password => @janky.password}}).returns(json)

    assert @janky.is_branch_green?('app', 'branch', 'hash')
  end

  def test_janky_is_branch_green_failed
    json = stub(:body => '[{"sha1":"different-hash","green":false}]')
    HTTParty.expects(:get).with("#{@janky.endpoint}/_hubot/app/branch", {:basic_auth => {:username => @janky.username, :password => @janky.password}}).returns(json)

    assert !@janky.is_branch_green?('app', 'branch', 'hash')
  end

  def test_janky_is_branch_green_missing
    json = stub(:body => '[{"sha1":"different-hash"}]')
    HTTParty.expects(:get).with("#{@janky.endpoint}/_hubot/app/branch", {:basic_auth => {:username => @janky.username, :password => @janky.password}}).returns(json)

    assert !@janky.is_branch_green?('app', 'branch', 'hash')
  end
end
