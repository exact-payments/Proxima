
module Proxima
  class Api

    attr_reader :base_uri, :headers

    def initialize(base_url, opts = {})
      @base_uri = URI.parse base_url
      @headers  = opts[:headers] || {}
    end

    HTTP_METHODS.each do |http_method|
      define_method http_method do |path, opts = {}, &block|
        self.request http_method, path, opts, &block
      end
    end

    def request(method, path, opts = {}, &block)
      Proxima::Request.new(self, method, path, opts, &block).response
    end
  end
end
