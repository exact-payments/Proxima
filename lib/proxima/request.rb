
module Proxima
  class Request

    attr_reader :response
    attr_reader :method
    attr_reader :uri
    attr_reader :headers
    attr_reader :body

    def initialize(api, method, path, opts = {})
      @api    = api
      @method = method.to_s.upcase

      headers = opts[:headers] || {}

      @body = if opts[:json]
        headers[:content_type] = 'application/json'
        opts[:json].to_json
      elsif opts[:body]
        opts[:body]
      end

      headers.merge! @api.headers

      @headers  = headers.map{ |name, val| [to_header(name), val.to_s] }.to_h
      query_str = opts[:query] ? "?#{opts[:query].to_query}" : ''
      @uri      = URI.join(@api.base_uri, path, query_str)
    end

    def response
      raw_response = @api.http
        .use(:auto_deflate)
        .headers(@headers)
        .request @method, @uri, body: @body, ssl_context: @api.ssl_context

      Response.new self, raw_response
    end

    private

    def to_header symbol_or_string
      symbol_or_string.to_s.split(/[_ -]/).map!{ |w| w.downcase.capitalize }.join '-'
    end
  end
end
