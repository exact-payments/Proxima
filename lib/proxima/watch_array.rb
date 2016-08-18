

module Proxima

  def self.watch_array(array, &on_change)

    array.instance_variable_set(:@on_change, on_change)

    array.each do |value|
      Proxima.watch(value, &on_change)
    end

    class << array

      def <<(*args)
        result = super
        args.each do |value|
          Proxima.watch(value, &@on_change)
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

      def clear(*args)
        result = super
        @on_change.call
        result
      end

      def collect!(*args)
        result = super
        @on_change.call
        result
      end

      def compact!(*args)
        result = super
        @on_change.call if result
        result
      end

      def delete(*args)
        result = super
        @on_change.call if result
        result
      end

      def delete_at(*args)
        result = super
        @on_change.call if result
        result
      end

      def delete_if(*args)
        result = super
        @on_change.call
        result
      end

      def fill(*args)
        result = super
        @on_change.call
        result
      end

      def flatten!(*args)
        result = super
        @on_change.call
        result
      end

      def replace(*args)
        result = super
        @on_change.call
        result
      end

      def insert(*args)
        args[1..-1].each do |value|
          Proxima.watch(value, &@on_change)
        end
        result = super
        @on_change.call if args[1] != nil
        result
      end

      def pop(*args)
        result = super
        @on_change.call if args[0] == nil || args[0] > 0
        result
      end

      def push(*args)
        args.each do |value|
          Proxima.watch(value, &@on_change)
        end
        result = super
        @on_change.call if args.length > 0
        result
      end

      def reject!(*args)
        result = super
        @on_change.call if result
        result
      end

      def reverse!(*args)
        result = super
        @on_change.call
        result
      end

      def rotate!(*args)
        result = super
        @on_change.call if args[0] != 0
        result
      end

      def select!(*args)
        result = super
        @on_change.call if result
        result
      end

      def shift(*args)
        result = super
        @on_change.call if args[0] == nil || args[0] > 0
        result
      end

      def shuffle!(*args)
        result = super
        @on_change.call
        result
      end

      def slice!(*args)
        result = super
        if result.is_a? Array
          @on_change.call if result.length > 0
        else
          @on_change.call if result != nil
        end
        result
      end

      def sort!(*args)
        result = super
        @on_change.call
        result
      end

      def sort_by!(*args)
        result = super
        @on_change.call
        result
      end

      def uniq!(*args)
        result = super
        @on_change.call if result
        result
      end
    end
  end
end
