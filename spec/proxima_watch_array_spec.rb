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
          Proxima.watch_array array, &b
          array << 1
          expect(array).to include(1)
        }.to yield_control
      end

      it 'causes watch_array to yield if an array is passed via << then modified' do
        array     = []
        sub_array = []
        expect { |b|
          Proxima.watch_array array, &b
          array << sub_array
          sub_array << 1
          expect(array).to include([1])
        }.to yield_control.twice
      end

      it 'calls Proxima.watch on each array or hash inserted' do
        sub_array = [2]
        array     = [1]
        Proxima.watch_array(array) {}
        expect(Proxima).to receive(:watch).with(sub_array)
        array << sub_array
      end
    end

    describe 'array.[]=' do

      it 'causes watch_array to yield when the array receives []= for assignment' do
        array = []
        expect { |b|
          Proxima.watch_array array, &b
          array[0] = 1
          expect(array).to include(1)
        }.to yield_control
      end

      it 'causes watch_array to yield when the array receives []= for range assignment' do
        array = [2]
        expect { |b|
          Proxima.watch_array array, &b
          array[0..1] = 1
          expect(array).to include(1)
          expect(array).to_not include(2)
        }.to yield_control
      end

      it 'causes watch_array to yield when the array receives []= for slice assignment' do
        array = [2]
        expect { |b|
          Proxima.watch_array array, &b
          array[0, 2] = 1
          expect(array).to include(1)
          expect(array).to_not include(2)
        }.to yield_control
      end

      it 'does not cause watch_array to yield when the array receives []= for access' do
        array = [1]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array[0]).to eql(1)
        }.not_to yield_control
      end

      it 'does not cause watch_array to yield when the array receives []= for range access' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array[0..1]).to eql([1, 2])
        }.not_to yield_control
      end

      it 'does not cause watch_array to yield when the array receives []= for slice access' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array[0, 2]).to eql([1, 2])
        }.not_to yield_control
      end

      it 'calls Proxima.watch on each array or hash inserted' do
        sub_array = [2]
        array     = [1]
        Proxima.watch_array(array) {}
        expect(Proxima).to receive(:watch).with(sub_array)
        array[0] = sub_array
      end
    end


    describe 'array.clear' do

      it 'causes watch_array to yield' do
        array = [1]
        expect { |b|
          Proxima.watch_array array, &b
          array.clear
          expect(array).not_to include(1)
        }.to yield_control
      end
    end


    describe 'array.collect!' do

      it 'causes watch_array to yield' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array array, &b
          array.collect! { |v| v + 1 }
          expect(array).to eql([2, 3])
        }.to yield_control
      end
    end


    describe 'array.compact!' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, nil, 2]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.compact!).to eql([1, 2])
          expect(array).to eql([1, 2])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.compact!).to eql(nil)
          expect(array).to eql([1, 2])
        }.not_to yield_control
      end
    end


    describe 'array.delete' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.delete(2)).to eql(2)
          expect(array).to eql([1, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.delete(3)).to eql(nil)
          expect(array).to eql([1, 2])
        }.not_to yield_control
      end
    end


    describe 'array.delete_at' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.delete_at(1)).to eql(2)
          expect(array).to eql([1, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.delete_at(3)).to eql(nil)
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end


    describe 'array.delete_if' do

      it 'causes watch_array to yield' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.delete_if { |val| val == 2 }).to eql([1, 3])
          expect(array).to eql([1, 3])
        }.to yield_control
      end
    end


    describe 'array.fill' do

      it 'causes watch_array to yield' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.fill(4)).to eql([4, 4, 4])
          expect(array).to eql([4, 4, 4])
        }.to yield_control
      end
    end


    describe 'array.flatten!' do

      it 'causes watch_array to yield' do
        array = [1, [2, 3]]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.flatten!).to eql([1, 2, 3])
          expect(array).to eql([1, 2, 3])
        }.to yield_control
      end
    end


    describe 'array.replace' do

      it 'causes watch_array to yield' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.replace([4, 5, 6])).to eql([4, 5, 6])
          expect(array).to eql([4, 5, 6])
        }.to yield_control
      end
    end


    describe 'array.insert' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.insert(1, 'x')).to eql([1, 'x', 2, 3])
          expect(array).to eql([1, 'x', 2, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.insert(1)).to eql([1, 2, 3])
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end

      it 'calls Proxima.watch on each array or hash inserted' do
        sub_array = [2]
        array     = [1]
        Proxima.watch_array(array) {}
        expect(Proxima).to receive(:watch).with(sub_array)
        array.insert(1, sub_array)
      end
    end


    describe 'array.pop' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.pop).to eql(3)
          expect(array).to eql([1, 2])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.pop(0)).to eql([])
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end


    describe 'array.push' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.push(4, 5)).to eql([1, 2, 3, 4, 5])
          expect(array).to eql([1, 2, 3, 4, 5])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.push).to eql([1, 2, 3])
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end


    describe 'array.reject!' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.reject! { |val| val == 2 }).to eql([1, 3])
          expect(array).to eql([1, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.reject! { |val| val == 4 }).to eql(nil)
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end


    describe 'array.reverse!' do

      it 'causes watch_array to yield' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.reverse!).to eql([3, 2, 1])
          expect(array).to eql([3, 2, 1])
        }.to yield_control
      end
    end


    describe 'array.rotate!' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.rotate!).to eql([2, 3, 1])
          expect(array).to eql([2, 3, 1])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.rotate!(0)).to eql([1, 2, 3])
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end


    describe 'array.select!' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.select! { |val| val != 2 }).to eql([1, 3])
          expect(array).to eql([1, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.select! { |val| val != 4 }).to eql(nil)
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end


    describe 'array.shift' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.shift).to eql(1)
          expect(array).to eql([2, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.shift(0)).to eql([])
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end


    describe 'array.shuffle!' do

      it 'causes watch_array to yield' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          array.shuffle!
        }.to yield_control
      end
    end


    describe 'array.slice!' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.slice!(1)).to eql(2)
          expect(array).to eql([1, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.slice!(0, 0)).to eql([])
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end


    describe 'array.sort!' do

      it 'causes watch_array to yield' do
        array = [2, 1, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.sort!).to eql([1, 2, 3])
          expect(array).to eql([1, 2, 3])
        }.to yield_control
      end
    end


    describe 'array.sort_by!' do

      it 'causes watch_array to yield' do
        array = [2, 1, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.sort_by! { |v1| v1 }).to eql([1, 2, 3])
          expect(array).to eql([1, 2, 3])
        }.to yield_control
      end
    end


    describe 'array.uniq!' do

      it 'causes watch_array to yield if the array changes' do
        array = [1, 2, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.uniq!).to eql([1, 2, 3])
          expect(array).to eql([1, 2, 3])
        }.to yield_control
      end

      it 'does not cause watch_array to yield if the array remains the same' do
        array = [1, 2, 3]
        expect { |b|
          Proxima.watch_array array, &b
          expect(array.uniq!).to eql(nil)
          expect(array).to eql([1, 2, 3])
        }.not_to yield_control
      end
    end
  end
end
