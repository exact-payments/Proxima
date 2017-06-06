require 'spec_helper'


describe Proxima do

  describe '.add_type' do

    it 'registers a type to be used by Proxima' do
      class MyType; end;

      Proxima.add_type MyType
    end
  end

  describe '.remove_type' do

    it 'unregisters a type'
  end

  describe '.type_from_json' do

    it 'converts a value from it\'s json parsed form into a given type'
  end

  describe '.type_to_json' do

    it 'converts a value from a given type to it\'s json parsed form'
  end
end
