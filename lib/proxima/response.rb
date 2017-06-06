
module Proxima
  class Response

    attr_reader :request

    def initialize(request, raw_response)
      @request      = request
      @raw_response = raw_response
    end

    def json
      begin
        JSON.parse @raw_response.body if @raw_response.body
      rescue => e
        raise "Failed to parse response body as JSON string: #{e.message}"
      end
    end

    def body
      @raw_response.body
    end

    def code
      @raw_response.code.to_i
    end

    def message
      @raw_response.message
    end

    def http_version
      @raw_response.http_version
    end
  end
end
