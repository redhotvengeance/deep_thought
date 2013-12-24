require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtTravisTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    @travis = DeepThought::CIService::Travis.new
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_travis_setup_success
    @travis.setup?({"CI_SERVICE_ENDPOINT" => "endpoint"})

    assert @travis.endpoint == 'endpoint'
  end

  def test_travis_is_branch_green_success
    json = stub(:body => '{"branch": {"status": "passed"}}')
    HTTParty.expects(:get).with("#{@travis.endpoint}/repos/Aaron1011/app/branches/branch").returns(json)

    assert @travis.is_branch_green?('Aaron1011/app', 'branch', 'hash')
  end

  def test_travis_is_branch_green_failed
    json = stub(:body => '{"branch": {"status": "failed"}}')
    HTTParty.expects(:get).with("#{@travis.endpoint}/repos/Aaron1011/app/branches/branch").returns(json)

    assert !@travis.is_branch_green?('Aaron1011/app', 'branch', 'hash')
  end
end
