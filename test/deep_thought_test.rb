require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    DeepThought.app
  end

  def test_hello_world
    get '/'
    assert last_response.ok?
    assert_equal "hello world", last_response.body
  end
end
