require File.expand_path '../test_helper.rb', __FILE__

class DeepThoughtCIServiceTest < MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.start

    DeepThought::CIService.adapters = {}
    DeepThought::CIService.ci_service = nil
  end

  def teardown
    DatabaseCleaner.clean
  end

  def test_no_ci_service
    DeepThought::CIService.setup({})

    assert !DeepThought::CIService.ci_service
  end

  def test_ci_service_not_found
    assert_raises(DeepThought::CIService::CIServiceNotFoundError) { DeepThought::CIService.setup({"CI_SERVICE" => "no-service"}) }
  end

  def test_ci_service_setup_failed
    ci_service = mock('class')
    ci_service.expects(:new).returns(ci_service)
    ci_service.expects(:setup?).with({"CI_SERVICE" => "mock"}).returns(false)
    DeepThought::CIService.register_adapter('mock', ci_service)
    assert_raises(DeepThought::CIService::CIServiceSetupFailedError) { DeepThought::CIService.setup({"CI_SERVICE" => "mock"}) }
  end

  def test_ci_service_is_branch_green_success
    ci_service = mock('class')
    ci_service.expects(:new).returns(ci_service)
    ci_service.expects(:setup?).with({"CI_SERVICE" => "mock"}).returns(true)
    ci_service.expects(:is_branch_green?).with('app', 'master', 'hash').returns(true)
    DeepThought::CIService.register_adapter('mock', ci_service)
    DeepThought::CIService.setup({"CI_SERVICE" => "mock"})
    assert DeepThought::CIService.is_branch_green?('app', 'master', 'hash')
  end

  def test_ci_service_is_branch_green_failed
    ci_service = mock('class')
    ci_service.expects(:new).returns(ci_service)
    ci_service.expects(:setup?).with({"CI_SERVICE" => "mock"}).returns(true)
    ci_service.expects(:is_branch_green?).with('app', 'master', 'hash').returns(false)
    DeepThought::CIService.register_adapter('mock', ci_service)
    DeepThought::CIService.setup({"CI_SERVICE" => "mock"})
    assert !DeepThought::CIService.is_branch_green?('app', 'master', 'hash')
  end
end
