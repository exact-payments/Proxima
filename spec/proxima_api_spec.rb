require 'spec_helper'


describe Proxima::Api do


  describe '#initialize' do

    before do
      @headers = { 'x-test-header': 'test' }
      @api     = Proxima::Api.new 'http://localhost:8100', headers: @headers
    end

    it 'sets @base_uri' do
      expect(@api.instance_variable_get('@base_uri')).to eql URI.parse('http://localhost:8100')
    end

    it 'sets @headers' do
      expect(@api.instance_variable_get('@headers')).to eql @headers
    end
  end


  Proxima::HTTP_METHODS.each do |verb|
    describe "##{verb}" do

      before do
        @api = Proxima::Api.new 'http://localhost:8100'
      end

      it "calls #request passing #{verb} as the method" do
        opts  = {}
        block = Proc.new {}

        expect(@api).to receive(:request).with verb, '/path', opts, &block

        @api.public_send verb, '/path', opts, &block
      end
    end
  end


  describe '#request' do

    before do
      @api = Proxima::Api.new 'http://localhost:8100'
    end

    it 'calls send on an instance of Proxima::Request and returns a Proxima::Response' do
      opts     = double 'opts'
      request  = instance_double Proxima::Request
      response = instance_double Proxima::Response

      expect(request).to receive(:response).and_return response
      expect(Proxima::Request).to receive(:new).with(@api, :get, '/path', opts).and_return request

      expect(@api.request(:get, '/path', opts)).to eq response
    end
  end
end
