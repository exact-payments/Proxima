require 'spec_helper'


describe Proxima::Response do

  describe '.json' do

    it 'returns the body parsed as json'

    it 'raises an exception if the body cannot be parsed as json'
  end

  describe '.body' do

    it 'returns the body'
  end

  describe '.code' do

    it 'returns the code'
  end

  describe '.message' do

    it 'returns the message associated with the code'
  end

  describe '.http_version' do

    it 'returns the http version used'
  end
end
