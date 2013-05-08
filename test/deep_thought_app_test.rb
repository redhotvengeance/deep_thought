require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtAppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include Capybara::DSL

  def setup
    DatabaseCleaner.start

    @user_email = 'test@test.com'
    @user_password = 'secret'
    @user = DeepThought::User.create(:email => @user_email, :password => @user_password, :password_confirmation => @user_password)
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver

    DatabaseCleaner.clean
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

  def test_user_generate_api_key
    login(@user_email, @user_password)

    visit "/users/#{@user.id}"
    assert_equal "http://www.example.com/users/#{@user.id}", page.current_url
    assert page.has_content?('no api key (yet)')

    DeepThought::User.any_instance.expects(:generate_api_key)

    @user.api_key = '12345'
    @user.save!

    within(".user-api-key") do
      click_button 'generate new api key'
    end

    assert_equal "http://www.example.com/users/#{@user.id}", page.current_url
    assert page.has_content?('12345')
  end
end
