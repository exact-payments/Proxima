require 'spec_helper'


describe Proxima do


  describe '#watch_array' do

    it 'calls Proxima.watch on each array or hash in the array' do
      sub_array = [2]
      array     = [1, sub_array]
      expect(Proxima).to receive(:watch).with(1)
      expect(Proxima).to receive(:watch).with(sub_array)
      Proxima.watch_array(array)
    end


    describe 'array.<<' do

      it 'causes watch_array to yield when the array receives <<' do
        array = []
        expect { |b|
          Proxima.watch_array(array, &b)
          array << 1
          expect(array).to include(1)
        }.to yield_control
      end

      it 'causes watch_array to yield if an array is passed via << then modified' do
        array     = []
        sub_array = []
        expect { |b|
          Proxima.watch_array(array, &b)
          array << sub_array
          sub_array << 1
          expect(array).to include([1])
        }.to yield_control.twice
      end
    end

    describe 'array.[]=' do

      it 'causes watch_array to yield when the array receives []= for assignment' do
        array = []
        expect { |b|
          Proxima.watch_array(array, &b)
          array[0] = 1
          expect(array).to include(1)
        }.to yield_control
      end

      it 'causes watch_array to yield when the array receives []= for range assignment' do
        array = [2]
        expect { |b|
          Proxima.watch_array(array, &b)
          array[0..1] = 1
          expect(array).to include(1)
          expect(array).to_not include(2)
        }.to yield_control
      end

      it 'causes watch_array to yield when the array receives []= for slice assignment' do
        array = [2]
        expect { |b|
          Proxima.watch_array(array, &b)
          array[0, 2] = 1
          expect(array).to include(1)
          expect(array).to_not include(2)
        }.to yield_control
      end

      it 'does not cause watch_array to yield when the array receives []= for access' do
        array = [1]
        expect { |b|
          Proxima.watch_array(array, &b)
          expect(array[0]).to eql(1)
        }.not_to yield_control
      end

      it 'does not cause watch_array to yield when the array receives []= for range access' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array(array, &b)
          expect(array[0..1]).to eql([1, 2])
        }.not_to yield_control
      end

      it 'does not cause watch_array to yield when the array receives []= for slice access' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array(array, &b)
          expect(array[0, 2]).to eql([1, 2])
        }.not_to yield_control
      end
    end


    describe 'array.clear' do

      it 'causes watch_array to yield if the array has contents' do
        array = [1]
        expect { |b|
          Proxima.watch_array(array, &b)
          array.clear
          expect(array).not_to include(1)
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array is empty' do
        array = []
        expect { |b|
          Proxima.watch_array(array, &b)
          array.clear
        }.not_to yield_control
      end
    end


    describe 'array.collect!' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array(array, &b)
          array.collect! { |v| v + 1 }
          expect(array).to eql([2, 3])
        }.to yield_control
      end

      it 'causes watch_array to yield if the array changes using an enumerator' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array(array, &b)
          enum = array.collect!
          enum.with_index { |v, i| v + i }
          expect(array).to eql([1, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array(array, &b)
          array.collect! { |v| v }
          expect(array).to eql([1, 2])
        }.not_to yield_control
      end
    end


    describe 'array.compact!' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, nil, 2]
        expect { |b|
          Proxima.watch_array(array, &b)
          expect(array.compact!).to eql([1, 2])
          expect(array).to eql([1, 2])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array(array, &b)
          expect(array.compact!).to eql(nil)
          expect(array).to eql([1, 2])
        }.not_to yield_control
      end
    end
  end
end
