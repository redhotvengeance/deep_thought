require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtAppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    DeepThought.app
  end

  def test_app_root
    get '/'
    assert last_response.ok?
    assert_equal "hello world", last_response.body
  end
end
