

module Proxima

  def self.watch_array(array, &on_change)

    array.instance_variable_set(:@on_change, on_change)

    array.each do |obj|
      Proxima.watch(obj, &on_change)
    end

    class << array

      def <<(*args)
        result = super
        args.each do |obj|
          Proxima.watch(obj, &@on_change)
        end
        @on_change.call
        result
      end

      def []=(*args)
        result = super
        Proxima.watch(args[2] || args[1], &@on_change)
        @on_change.call
        result
      end

      def clear
        has_contents = self.length > 0
        result = super
        @on_change.call if has_contents
        result
      end

      def collect!
        prev = self.dup
        result = super
        @on_change.call unless self == prev
        result
      end

      def compact!
        prev_length = self.length
        result = super
        @on_change.call if result
        result
      end

      def delete(value)
        prev = self.dup
        result = super
        @on_change.call unless self == prev
        result
      end

      def delete_at(index)
        prev = self.dup
        super
        @on_change.call unless self == prev
      end

      def delete_if
        prev = self.dup
        super
        @on_change.call unless self == prev
      end

      def drop(n = nil)
        super
        @on_change.call unless n == 0
      end

      def drop_while
        prev = self.dup
        super
        @on_change.call unless self == prev
      end

      def fill
        super
        @on_change.call
      end

      def flatten!(level = nil)
        prev = self.dup
        super
        @on_change.call unless self == prev
      end

      def replace(other_ary)
        prev = self.dup
        super
        @on_change.call unless self == prev
      end

      def insert(index, value)
        prev = self.dup
        Proxima.watch(value, &@on_change)
        super
        @on_change.call unless self == prev
      end

      def pop(n = nil)
        super
        @on_change.call
      end

      def push(*obj_ary)
        obj_ary.each do
          Proxima.watch(value, &@on_change)
        end
        super
        @on_change.call
      end

      def reject!
        super
        @on_change.call
      end

      def reverse!
        super
        @on_change.call
      end

      def rotate!(cnt=nil)
        super
        @on_change.call
      end

      def select!
        super
        @on_change.call
      end

      def shift(n = nil)
        super
        @on_change.call
      end

      def shuffle!(random = nil)
        super
        @on_change.call
      end

      def slice!(start, length = nil)
        super
        @on_change.call
      end

      def sort!
        super
        @on_change.call
      end

      def sort_by!
        super
        @on_change.call
      end

      def uniq!
        super
        @on_change.call
      end
    end
  end
end
