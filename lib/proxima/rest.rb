

module Proxima

  module Rest

    [:post, :get, :put, :delete].each do |http_method|
      define_method :"#{http_method}" do |path, opts = {}, &block|
        @response = self.class.api.public_send(:"#{http_method}", path, opts, &block)
        @response
      end
    end

    module ClassMethods

      [:post, :get, :put, :delete].each do |http_method|
        define_method :"#{http_method}" do |path, opts = {}, &block|
          @response = self.api.public_send(:"#{http_method}", path, opts, &block)
          @response
        end
      end
    end

    def self.included base
      base.extend ClassMethods
    end
  end
end
