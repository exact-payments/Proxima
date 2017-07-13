

module Proxima
  module Serialization

    def from_json(json, opts = {})
      json = ActiveSupport::JSON.decode(json) if json.is_a?(String)
      json = json.values.first if opts[:include_root] || self.include_root_in_json
      json = json.first        if opts[:single_model_from_array] && json.is_a?(Array)
      hash = {}

      self.class.attributes.each do |attribute, params|
        json_path        = params[:json_path]
        json_path_chunks = json_path.split '.'
        json_ctx         = json
        for json_path_chunk in json_path_chunks
          json_ctx = json_ctx[json_path_chunk]
          break if json_ctx.nil?
        end
        value = json_ctx

        next if value.nil?

        if params[:klass]
          begin
            value = Proxima.type_from_json params[:klass], value
          rescue Exception => e
            raise "Cannot convert value \"#{value}\" for attribute \"#{attribute}\" to type" +
              " #{params[:klass].name}: #{e.message}"
          end
        end

        hash[attribute] = value
      end

      self.attributes = hash
      self.new_record = opts[:new_record] if opts[:new_record] != nil
      self
    end

    def as_json(opts = {})
      hash = self.serializable_hash opts

      json = {}
      self.class.attributes.each do |attribute, params|
        next if (
          !opts.key?(:include_clean) && !send("#{attribute}_changed?") ||
          !opts.key?(:include_nil)   && hash[attribute.to_s] == nil
        )

        json_path = params[:json_path]
        value     = hash[attribute.to_s]

        if params[:klass]
          begin
            value = Proxima.type_to_json params[:klass], value
          rescue Exception => e
            raise "Cannot convert value \"#{value}\" for attribute \"#{attribute}\" from type" +
              " #{params[:klass].name}: #{e.message}"
          end
        end

        if opts.key? :flatten
          json[json_path] = value
          next
        end

        json_path_chunks     = json_path.split '.'
        last_json_path_chunk = json_path_chunks.pop
        json_ctx             = json
        for json_path_chunk in json_path_chunks
          json_ctx[json_path_chunk] = {} unless json_ctx[json_path_chunk].is_a?(Hash)
          json_ctx = json_ctx[json_path_chunk]
        end
        json_ctx[last_json_path_chunk] = value
      end

      root = if opts.key? :root
        opts[:root]
      else
        self.include_root_in_json
      end

      if root
        root = self.class.model_name.element if root == true
        { root => json }
      else
        json
      end
    end

    def to_h
      hash = {}
      self.class.attributes.each do |attribute, params|
        hash[attribute] = self.send attribute
      end
      hash
    end

    module ClassMethods

      def from_json(json, opts = {})
        json = ActiveSupport::JSON.decode(json) if json.is_a? String
        json = json.values.first if opts[:include_root] || self.include_root_in_json
        json = json.first        if opts[:single_model_from_array] && json.is_a?(Array)

        if json.is_a? Array
          return json.map { |json| self.new.from_json json }
        end

        model            = self.new.from_json json
        model.new_record = opts[:new_record] || false

        model
      end

      def convert_query_or_delta_to_json(query)
        json_query = {}
        query.each do |attribute, val|
          attr_str  = attribute.to_s
          json_path = attributes[attribute] ? attributes[attribute][:json_path] : attr_str

          json_query[json_path] = unless attr_str[0] == '$' && val.is_a?(Hash)
            val
          else
            self.convert_query_or_delta_to_json val
          end
        end
        json_query
      end
    end

    def self.included base
      base.extend ClassMethods
    end
  end
end
