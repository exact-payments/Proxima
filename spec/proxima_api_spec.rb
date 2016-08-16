require 'spec_helper'


describe Proxima::Api do


  describe '#initialize' do

    before do
      @headers = { 'X-TEST-HEADER': 'test' }
      @api     = Proxima::Api.new('BASE_URL', headers: @headers)
    end

    it 'sets @baseUrl' do
      expect(@api.instance_variable_get('@base_url')).to eql('BASE_URL')
    end

    it 'sets @headers' do
      expect(@api.instance_variable_get('@headers')).to eql(@headers)
    end
  end


  ['post', 'get', 'put', 'delete'].each do |verb|
    describe "##{verb}" do

      before do
        @api = Proxima::Api.new('BASE_URL')
      end

      it "calls #request passing #{verb} as the method" do
        opts  = {}
        block = Proc.new {}
        expect(@api).to receive(:request).with(verb.to_sym, 'PATH', opts, &block)
        @api.public_send(verb, 'PATH', opts, &block)
      end
    end
  end


  describe '#request' do

    before do
      @api = Proxima::Api.new('BASE_URL')
    end

    it 'calls RestClient::Request.execute passing it the method, url, headers, and payload' do
      headers = { 'X-TEST-HEADER': 'test' }
      query   = { q: 1 }
      payload = { j: 1 }

      expect(RestClient::Request).to receive(:execute).with({
        method:  'METHOD',
        url:     'BASE_URL/PATH',
        headers: {
          'X-TEST-HEADER': 'test',
          params: { q: 1 },
          content_type: :json
        },
        payload: payload.to_json
      }).and_yield

      expect { |b|
        @api.request('METHOD', '/PATH', {
          headers: headers,
          query:   query,
          json:    payload
        }, &b)
      }.to yield_control
    end
  end
end
