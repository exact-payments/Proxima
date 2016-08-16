require 'active_model'
require 'proxima/watch'


module Proxima

  class Model
    include ActiveModel::AttributeMethods
    include ActiveModel::Conversion
    include ActiveModel::Dirty
    include ActiveModel::Validations
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON
    extend  ActiveModel::Callbacks
    extend  ActiveModel::Naming
    extend  ActiveModel::Translation

    # TODO: Implement callbacks
    # define_model_callbacks :create, :update

    def read_attribute_for_validation(attr)
      send(attr)
    end

    def initialize(params = {})
      params ||= {} # FIXME: not sure why this is needed, but it seems to be
      self.new_record = !params.has_index?(:id)
      self.attributes = params
    end

    def self.api(api = nil)
      @api = api if api
      @api
    end

    def self.base_uri(base_uri = nil)
      @base_uri = base_uri if base_uri
      @base_uri
    end

    # TODO: Make path defaults settable from the api class
    def self.create_path(create_path = nil)
      create_path = ->() { create_path } if create_path.is_a?(String)
      @create_path = create_path if create_path
      @create_path ||= ->() { "#{base_uri}" }
    end

    def self.find_path(find_path = nil)
      find_path = ->(m) { find_path } if find_path.is_a?(String)
      @find_path = find_path if find_path
      @find_path ||= ->(m) { "#{base_uri}/#{m[:id]}" }
    end

    def self.query_path(query_path = nil)
      query_path = ->() { query_path } if query_path.is_a?(String)
      @query_path = query_path if query_path
      @query_path ||= ->() { "#{base_uri}" }
    end

    def self.update_path(update_path = nil)
      update_path = ->(m) { update_path } if update_path.is_a?(String)
      @update_path = update_path if update_path
      @update_path ||= ->(m) { "#{base_uri}/#{m[:id]}" }
    end

    def self.delete_path(delete_path = nil)
      delete_path = ->(m) { delete_path } if delete_path.is_a?(String)
      @delete_path = delete_path if delete_path
      @delete_path ||= ->(m) { "#{base_uri}/#{m[:id]}" }
    end

    def self.restore_path(restore_path = nil)
      restore_path = ->(m) { restore_path } if restore_path.is_a?(String)
      @restore_path = restore_path if restore_path
      @restore_path ||= ->(m) { "#{base_uri}/restore/#{m[:id]}" }
    end

    def self.attributes
      @attributes ||= {}
    end

    def self.attribute(attribute, klass = nil, json_path = nil, params = nil)
      params ||= json_path if json_path.is_a?(Hash)
      params ||= klass     if klass.is_a?(Hash)
      params ||= {}

      params[:klass]     ||= klass     if klass.is_a?(Class)
      params[:json_path] ||= json_path if json_path.is_a?(String)
      params[:json_path] ||= klass     if klass.is_a?(String)
      params[:json_path] ||= attribute.to_s

      # Create attribute accessors
      attr_reader attribute
      define_method("#{attribute}=") do |value|
        self.persisted = false
        attribute_will_change!(attribute)
        instance_variable_set("@#{attribute}", value)
        Proxima.watch(value) do
          attribute_will_change!(attribute)
        end
      end

      # Create attribute? methods
      define_method("#{attribute}?") do
        instance_variable_get("@#{attribute}") != nil
      end

      # Create suffixed/prefixed attribute methods
      define_attribute_method attribute

      attributes[attribute] = params
    end

    def self.create(params)
      return params.map { |params| new(params) } if params.is_a?(Array)
      new(params).save
    end

    def self.find(id, params = {})
      return nil unless id

      response = api.get(find_path.call({ id: id }), params)

      return nil unless response.code == 200

      model = new()
      model.from_json(response.body)
      model.new_record = false
      model
    end

    def self.query(query, params = {})
      params[:query] = convert_query_or_delta_to_json(query)
      response = api.get(query_path.call(), params)

      return [] unless response.code == 200

      params = ActiveSupport::JSON.decode(response.body)
      params.map do |params|
        model = new
        model.from_json(params)
        model.new_record = false
        model
      end
    end

    def self.search(query, params = {})
      self.query(query, params)
    end

    def self.count(query)
      params[:query]   = convert_query_or_delta_to_json(query)
      params['$limit'] = 0
      response = api.get(query_path.call(), params)

      return nil unless response.code == 200

      response.headers[:x_total_count] || 0
    end

    def self.errors
      @errors ||= ActiveModel::Errors.new(self)
    end

    def self.convert_query_or_delta_to_json(query)
      json_query = {}
      query.each do |attribute, val|
        attr_str  = attribute.to_s
        json_path = attributes[attribute] ? attributes[attribute][:json_path] : attr_str

        json_query[json_path] = unless attr_str[0] == '$' && val.is_a?(Hash)
          val
        else
          convert_query_or_delta_to_json(val)
        end
      end
      json_query
    end

    def persisted?
      @persisted
    end

    def persisted=(val)
      @persisted = !!val
      changes_applied if val
    end

    def new_record?
      @new_record
    end

    def new_record=(val)
      @new_record = !!val
      @persisted  = !val
      clear_changes_information unless val
    end

    # TODO: Better support soft delete

    def to_h
      hash = {}
      self.class.attributes.each do |attribute, params|
        hash[attribute] = send(attribute)
      end
      hash
    end

    def attributes
      attributes_hash = {}
      self.class.attributes.each do |attribute, params|
        value = send(attribute)
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
          value = klass.respond_to?(:new) ? klass.new(value) : method(klass.to_s).call(value)
        end

        self.send("#{attribute}=", value)
      end
    end

    def self.from_json(json, include_root=include_root_in_json)
      json = ActiveSupport::JSON.decode(json) if json.is_a?(String)
      json = json.values.first if include_root

      if json.is_a?(Array)
        return json.map { |json| new.from_json(json) }
      end

      new.from_json(json)
    end

    def from_json(json, include_root=include_root_in_json)
      json = ActiveSupport::JSON.decode(json) if json.is_a?(String)
      json = json.values.first if include_root
      hash = {}

      self.class.attributes.each do |attribute, params|
        json_path        = params[:json_path]
        json_path_chunks = json_path.split('.')
        json_ctx         = json
        for json_path_chunk in json_path_chunks
          json_ctx = json_ctx[json_path_chunk]
          break if json_ctx.nil?
        end
        value = json_ctx

        next unless value

        if params[:klass] && params[:klass].respond_to?(:from_json)
          value = params[:klass].from_json(value)
        end

        hash[attribute] = value
      end

      self.attributes = hash
      self
    end

    def as_json(options = {})

      root = if options.key?(:root)
        options[:root]
      else
        include_root_in_json
      end

      hash = serializable_hash(options);
      json = {}
      self.class.attributes.each do |attribute, params|
        next if (
          !options.key?(:include_clean) && !send("#{attribute}_changed?") ||
          !options.key?(:include_nil) && hash[attribute.to_s] == nil
        )

        json_path = params[:json_path]
        value     = hash[attribute.to_s]
        value     = value.as_json if value.respond_to?(:as_json)

        if options.key?(:flatten)
          json[json_path] = value
          next
        end

        json_path_chunks     = json_path.split('.')
        last_json_path_chunk = json_path_chunks.pop
        json_ctx             = json
        for json_path_chunk in json_path_chunks
          json_ctx[json_path_chunk] = {} unless json_ctx[json_path_chunk].is_a?(Hash)
          json_ctx = json_ctx[json_path_chunk]
        end
        json_ctx[last_json_path_chunk] = value
      end

      if root
        root = self.class.model_name.element if root == true
        { root => json }
      else
        json
      end
    end

    def save(options = {})
      return false unless valid?

      if new_record?
        response = self.class.api.post(self.class.create_path.call, {
          json: as_json(options)
        })

        return false unless response.code == 201

        from_json(response.body, options[:include_root])
        self.new_record = false
        return true
      end

      options[:flatten] = true if options[:flatten] == nil
      response = self.class.api.put(self.class.update_path.call(self.to_h), {
        json: as_json(options)
      })

      return false unless response.code == 204
      self.persisted = true
    end

    def reload!
      clear_changes_information
    end

    def rollback!
      restore_attributes
    end

    def destroy
      return false if new_record?

      response = self.class.api.delete(self.class.delete_path.call(self.to_h))

      return false unless response.code == 204
      self.persisted = true
    end

    def restore
      return false if new_record?

      response = self.class.api.post(self.class.restore_path.call(self.to_h))

      return false unless response.code == 204
      self.persisted = true
    end
  end
end
