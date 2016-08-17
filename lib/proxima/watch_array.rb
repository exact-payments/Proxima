

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

      def clear
        result = super
        @on_change.call
        result
      end

      def collect!
        result = super
        @on_change.call
        result
      end

      def compact!
        result = super
        @on_change.call if result
        result
      end

      def delete
        result = super
        @on_change.call if result
        result
      end

      def delete_at
        result = super
        @on_change.call if result
        result
      end

      def delete_if
        result = super
        @on_change.call
        result
      end

      def drop(*args)
        result = super
        @on_change.call if args[0] > 0
        result
      end

      def drop_while
        result = super
        @on_change.call
        result
      end

      def fill
        result = super
        @on_change.call
        result
      end

      def flatten!
        result = super
        @on_change.call
        result
      end

      def replace
        result = super
        @on_change.call
        result
      end

      def insert(*args)
        args[1..-1].each do |value|
          Proxima.watch(value, &@on_change)
        end
        result = super
        @on_change.call
        result
      end

      def pop(*args)
        result = super
        @on_change.call if args[0] > 0
        result
      end

      def push(*args)
        args.each do |value|
          Proxima.watch(value, &@on_change)
        end
        result = super
        @on_change.call if args.length
        result
      end

      def reject!
        result = super
        @on_change.call if result
        result
      end

      def reverse!
        result = super
        @on_change.call
        result
      end

      def rotate!
        result = super
        @on_change.call
        result
      end

      def select!
        result = super
        @on_change.call
        result
      end

      def shift(*args)
        result = super
        @on_change.call if args[0] > 0
        result
      end

      def shuffle!
        result = super
        @on_change.call
        result
      end

      def slice!
        result = super
        @on_change.call
        result
      end

      def sort!
        result = super
        @on_change.call
        result
      end

      def sort_by!
        result = super
        @on_change.call
        result
      end

      def uniq!
        result = super
        @on_change.call if result
        result
      end
    end
  end
end
