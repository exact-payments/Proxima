
module Proxima
  class Response

    attr_reader :request

    def initialize(request, raw_response)
      @request      = request
      @raw_response = raw_response
      @headers      = nil

      @raw_response.flush
    end

    def json
      @raw_response.parse 'application/json'
    end

    def body
      @raw_response.body.to_s
    end

    def code
      @raw_response.code
    end

    def message
      @raw_response.reason
    end

    def headers
      @headers ||= @raw_response.headers.map{ |name, value| [from_header(name), value] }.to_h
    end

    private

    def from_header header_name
      header_name.downcase.gsub('-', '_').to_sym
    end
  end
end
