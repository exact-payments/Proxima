require 'spec_helper'


describe Proxima do


  describe '#watch' do

    it 'calls #watch_array if an array is passed' do
      expect(Proxima).to receive(:watch_array)
      Proxima.watch([])
    end

    it 'calls #watch_hash if a hash is passed' do
      expect(Proxima).to receive(:watch_hash)
      Proxima.watch({})
    end
  end
end
