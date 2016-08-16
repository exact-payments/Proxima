

module Proxima

  def watch_array(array, &block)
    class << array

      def <<(obj, *args)
        hook_change_hander(obj, &block)
        super
        block.call
      end

      def []=(start, length, obj = nil)
        obj = length unless obj
        hook_change_hander(obj, &block)
        super
        block.call
      end

      def clear
        super
        block.call
      end

      def collect!
        prev = dup
        super
        block.call unless self == prev
      end

      def compact!
        prev = dup
        super
        block.call unless self == prev
      end

      def delete(value)
        prev = dup
        super
        block.call unless self == prev
      end

      def delete_at(index)
        prev = dup
        super
        block.call unless self == prev
      end

      def delete_if
        prev = dup
        super
        block.call unless self == prev
      end

      def drop(n = nil)
        super
        block.call unless n == 0
      end

      def drop_while
        prev = dup
        super
        block.call unless self == prev
      end

      def fill
        super
        block.call
      end

      def flatten!(level = nil)
        prev = dup
        super
        block.call unless self == prev
      end

      def replace(other_ary)
        prev = dup
        super
        block.call unless self == prev
      end

      def insert(index, value)
        prev = dup
        hook_change_hander(value, &block)
        super
        block.call unless self == prev
      end

      def pop(n = nil)
        super
        block.call
      end

      def push(*obj_ary)
        obj_ary.each do
          hook_change_hander(value, &block)
        end
        super
        block.call
      end

      def reject!
        super
        block.call
      end

      def reverse!
        super
        block.call
      end

      def rotate!(cnt=nil)
        super
        block.call
      end

      def select!
        super
        block.call
      end

      def shift(n = nil)
        super
        block.call
      end

      def shuffle!(random = nil)
        super
        block.call
      end

      def slice!(start, length = nil)
        super
        block.call
      end

      def sort!
        super
        block.call
      end

      def sort_by!
        super
        block.call
      end

      def uniq!
        super
        block.call
      end
    end
  end
end
