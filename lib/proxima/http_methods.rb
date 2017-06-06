

module Proxima

  HTTP_METHODS = [:head, :post, :get, :put, :delete]

  module HTTPMethods

    HTTP_METHODS.each do |http_method|
      define_method http_method do |path, opts = {}, &block|
        @response = self.class.api.public_send(http_method, path, opts, &block)
        @response
      end
    end

    module ClassMethods

      HTTP_METHODS.each do |http_method|
        define_method http_method do |path, opts = {}, &block|
          @response = self.api.public_send(http_method, path, opts, &block)
          @response
        end
      end
    end

    def self.included base
      base.extend ClassMethods
    end
  end
end
