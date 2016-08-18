require 'spec_helper'


describe Proxima do


  describe '#watch_hash' do

    it 'calls Proxima.watch on each array or hash in the hash' do
      sub_hash = { a: 2 }
      hash     = { a: 1, b: sub_hash }
      expect(Proxima).to receive(:watch).with(1)
      expect(Proxima).to receive(:watch).with(sub_hash)
      Proxima.watch_hash(hash)
    end


    describe 'hash.[]=' do

      it 'causes watch_hash to yield when the hash receives []= for assignment' do
        hash = {}
        expect { |b|
          Proxima.watch_hash hash, &b
          hash[:a] = 1
          expect(hash).to include({ a: 1 })
        }.to yield_control
      end

      it 'does not cause watch_hash to yield when the hash receives []= for access' do
        hash = { a: 1 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash[:a]).to eql(1)
        }.not_to yield_control
      end

      it 'calls Proxima.watch on each array or hash inserted' do
        sub_hash = { a: 2 }
        hash     = { a: 1 }
        Proxima.watch_hash(hash) {}
        expect(Proxima).to receive(:watch).with(sub_hash)
        hash[:b] = sub_hash
      end
    end


    describe 'hash.clear' do

      it 'causes watch_hash to yield' do
        hash = { a: 1 }
        expect { |b|
          Proxima.watch_hash hash, &b
          hash.clear
          expect(hash).not_to include({ a: 1 })
        }.to yield_control
      end
    end


    describe 'hash.delete' do

      it 'causes watch_hash to yield if the hash changes' do
        hash = { a: 1, b: 2, c: 3 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.delete(:b)).to eql(2)
          expect(hash).to eql({ a: 1, c: 3 })
        }.to yield_control
      end

      it 'does not cause watch_hash to yield if the hash remains the same' do
        hash = { a: 1, b: 2 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.delete(:c)).to eql(nil)
          expect(hash).to eql({ a: 1, b: 2 })
        }.not_to yield_control
      end
    end


    describe 'hash.delete_if' do

      it 'causes watch_hash to yield' do
        hash = { a: 1, b: 2, c: 3 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.delete_if { |key, val| val == 2 }).to eql({ a: 1, c: 3 })
          expect(hash).to eql({ a: 1, c: 3 })
        }.to yield_control
      end
    end


    describe 'merge!' do

      it 'causes watch_hash to yield' do
        other_hash = { b: 2 }
        hash       = { a: 1 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.merge!(other_hash)).to eql({ a: 1, b: 2 })
          expect(hash).to eql({ a: 1, b: 2 })
        }.to yield_control
      end

      it 'calls Proxima.watch on each array or hash inserted' do
        other_hash = { d: 2 }
        hash       = { a: 1 }
        Proxima.watch_hash(hash) {}
        expect(Proxima).to receive(:watch).with(2)
        hash.merge!(other_hash)
      end
    end


    describe 'hash.reject!' do

      it 'causes watch_hash to yield if the hash changes' do
        hash = { a: 1, b: 2, c: 3 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.reject! { |key, val| val == 2 }).to eql({ a: 1, c: 3 })
          expect(hash).to eql({ a: 1, c: 3 })
        }.to yield_control
      end

      it 'does not cause watch_hash to yield if the hash remains the same' do
        hash = { a: 1, b: 2, c: 3 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.reject! { |key, val| val == 4 }).to eql(nil)
          expect(hash).to eql({ a: 1, b: 2, c: 3 })
        }.not_to yield_control
      end
    end


    describe 'hash.select!' do

      it 'causes watch_hash to yield if the hash changes' do
        hash = { a: 1, b: 2, c: 3 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.select! { |key, val| val != 2 }).to eql({ a: 1, c: 3 })
          expect(hash).to eql({ a: 1, c: 3 })
        }.to yield_control
      end

      it 'does not cause watch_hash to yield if the hash remains the same' do
        hash = { a: 1, b: 2, c: 3 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.select! { |key, val| val != 4 }).to eql(nil)
          expect(hash).to eql({ a: 1, b: 2, c: 3 })
        }.not_to yield_control
      end
    end


    describe 'store' do

      it 'causes watch_hash to yield' do
        hash = { a: 1 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.store(:b, 2)).to eql(2)
          expect(hash).to eql({ a: 1, b: 2 })
        }.to yield_control
      end

      it 'calls Proxima.watch on each array or hash inserted' do
        hash = { a: 1 }
        Proxima.watch_hash(hash) {}
        expect(Proxima).to receive(:watch).with(2)
        hash.store(:b, 2)
      end
    end


    describe 'update' do

      it 'causes watch_hash to yield' do
        other_hash = { b: 2 }
        hash       = { a: 1 }
        expect { |b|
          Proxima.watch_hash hash, &b
          expect(hash.update(other_hash)).to eql({ a: 1, b: 2 })
          expect(hash).to eql({ a: 1, b: 2 })
        }.to yield_control
      end

      it 'calls Proxima.watch on each array or hash inserted' do
        other_hash = { d: 2 }
        hash       = { a: 1 }
        Proxima.watch_hash(hash) {}
        expect(Proxima).to receive(:watch).with(2)
        hash.update(other_hash)
      end
    end
  end
end
