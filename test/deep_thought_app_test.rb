require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtAppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include Capybara::DSL

  def setup
    @user_email = 'test@test.com'
    @user_password = 'secret'
    @user = DeepThought::User.create(:email => @user_email, :password => @user_password, :password_confirmation => 'secret')
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def app
    DeepThought.app
  end

  def test_app_root_logged_out
    get '/'
    follow_redirect!
    assert last_response.ok?
    assert_equal "http://example.org/login", last_request.url
  end

  def test_app_root_logged_in
    login(@user_email, @user_password)

    visit '/'
    assert_equal page.status_code, 200
    assert_equal "http://www.example.com/", page.current_url
  end

  def test_app_logout
    login(@user_email, @user_password)

    visit '/'
    assert_equal page.status_code, 200
    assert_equal "http://www.example.com/", page.current_url

    within(".logout") do
      click_button 'logout'
    end

    visit '/'
    assert_equal page.status_code, 200
    assert_equal "http://www.example.com/login", page.current_url
  end
end
