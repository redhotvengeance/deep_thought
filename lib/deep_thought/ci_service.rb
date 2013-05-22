module DeepThought
  module CIService
    class CIServiceNotFoundError < StandardError; end
    class CIBuildNotGreenError < StandardError; end
    class CIProjectAccessError < StandardError; end

    class << self
      attr_accessor :adapters, :ci_service
    end

    def self.adapters
      @adapters ||= {}
    end

    def self.register_adapter(name, service)
      self.adapters[name] = service
    end

    def self.setup(settings)
      if settings['CI_SERVICE']
        if @adapters.keys.include?(settings['CI_SERVICE'])
          klass = adapters[settings['CI_SERVICE']]
          @ci_service = klass.new
          @ci_service.setup(settings)
        else
          raise CIServiceNotFoundError, "I don't have a CI service called \"#{settings['CI_SERVICE']}\"."
        end
      end
    end

    def self.is_branch_green?(app, branch, hash)
      begin
        is_green = @ci_service.is_branch_green?(app, branch, hash)

        if !is_green
          raise CIBuildNotGreenError, "Commit #{hash} on project #{app} (in branch #{branch}) is not green. Fix it before deploying."
        end

        true
      rescue
        raise CIProjectAccessError, "Something went wrong with asking CI about commit #{hash} on project #{app} (in branch #{branch})."
      end
    end
  end
end
