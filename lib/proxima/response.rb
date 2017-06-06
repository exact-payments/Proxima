
module Proxima
  class Response

    attr_reader :request

    def initialize(request, raw_response)
      @request      = request
      @raw_response = raw_response
      @headers      = nil
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

    def headers
      @headers ||= @raw_response.each_header { |name, val| [from_header(name), val] }.to_h
    end

    private

    def from_header header_name
      header_name.downcase.gsub('-', '_').to_sym
    end
  end
end
