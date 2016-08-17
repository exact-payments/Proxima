

module Proxima
  module Validation

    def read_attribute_for_validation(attr)
      self.send attr
    end

    def self.errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    module ClassMethods

      def human_attribute_name(attr, options = {})
        attr
      end

      def lookup_ancestors
        [self]
      end
    end

    def self.included base
      base.extend ClassMethods
    end
  end
end
