

module Proxima
  module Attributes

    def attributes
      attributes_hash = {}
      self.class.attributes.each do |attribute, params|
        value = self.send attribute
        attributes_hash[attribute.to_s] = value
      end
      attributes_hash
    end

    def attributes=(params = {})
      self.class.attributes.each do |attribute, attribute_params|
        value = params[attribute]

        if value == nil && default = attribute_params[:default]
          value = default.respond_to?(:call) ? default.call(self, params) : default
        end

        if attribute_params[:klass] && !value.is_a?(attribute_params[:klass])
          klass = attribute_params[:klass]
          value = klass.new value
        end

        self.send "#{attribute}=", value
      end
    end

    module ClassMethods

      def attributes
        @attributes ||= {}
      end

      def attribute(attribute, klass = nil, json_path = nil, params = nil)
        params ||= json_path if json_path.is_a? Hash
        params ||= klass     if klass.is_a? Hash
        params ||= {}

        params[:klass]     ||= klass     if klass.is_a? Class
        params[:json_path] ||= json_path if json_path.is_a? String
        params[:json_path] ||= klass     if klass.is_a? String
        params[:json_path] ||= attribute.to_s

        # Create attribute accessors
        attr_reader attribute
        define_method("#{attribute}=") do |value|
          self.persisted = false
          attribute_will_change! attribute
          self.instance_variable_set "@#{attribute}", value
          Proxima.watch value do
            attribute_will_change! attribute
          end
        end

        # Create attribute? methods
        define_method "#{attribute}?" do
          self.instance_variable_get("@#{attribute}") != nil
        end

        # Create suffixed/prefixed attribute methods
        self.define_attribute_method attribute

        self.attributes[attribute] = params
      end
    end

    def self.included base
      base.extend ClassMethods
    end
  end
end
