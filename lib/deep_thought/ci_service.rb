module DeepThought
  module CIService
    def self.adapters
      @adapters ||= {}
    end

    def self.register_adapter(name, service)
      self.adapters[name] = service
    end
  end
end
