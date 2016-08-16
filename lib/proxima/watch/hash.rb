

module Proxima

  def self.watch_hash(hash, &block)
    class << hash

      def []=(key, value)
        hook_change_hander(value, &block)
        super
        block.call
      end

      def clear
        super
        block.call
      end

      def delete(key)
        super
        block.call
      end

      def delete_if
        super
        block.call
      end

      def merge!(other_hash)
        other_hash.values.each do
          hook_change_hander(value, &block)
        end
        super
        block.call
      end

      def reject!
        super
        block.call
      end

      def select!
        super
        block.call
      end

      def store(key, value)
        hook_change_hander(value, &block)
        super
        block.call
      end

      def update(other_hash)
        other_hash.values.each do
          hook_change_hander(value, &block)
        end
        super
        block.call
      end
    end
  end
end
