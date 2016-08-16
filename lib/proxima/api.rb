require 'rest-client'


module Proxima

  class Api

    attr_accessor :url, :headers

    def initialize(base_url, opts = {})
      @base_url = base_url
      @headers  = opts[:headers] || {}
    end

    def post(path, opts = {}, &block)
      self.request(:post, path, opts, &block)
    end

    def get(path, opts = {}, &block)
      self.request(:get, path, opts, &block)
    end

    def put(path, opts = {}, &block)
      self.request(:put, path, opts, &block)
    end

    def delete(path, opts = {}, &block)
      self.request(:delete, path, opts, &block)
    end

    def request(method, path, opts = {}, &block)
      headers = @headers.clone
      headers.merge!(opts[:headers])  if opts[:headers]
      headers[:params] = opts[:query] if opts[:query]
      headers[:content_type] = :json  if opts[:json]
      payload = opts[:json].to_json   if opts[:json]

      begin
        RestClient::Request.execute({
          method:  method,
          url:     @base_url + path,
          headers: headers,
          payload: payload
        }, &block)
      rescue RestClient::Exception => e
        e.response
      end
    end
  end
end
