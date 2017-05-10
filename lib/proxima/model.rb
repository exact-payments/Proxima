require 'active_model'
require 'proxima/watch'
require 'proxima/attributes'
require 'proxima/paths'
require 'proxima/serialization'
require 'proxima/validation'


module Proxima

  class Model
    extend  ActiveModel::Naming
    extend  ActiveModel::Translation
    include ActiveModel::AttributeMethods
    include ActiveModel::Conversion
    include ActiveModel::Dirty
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON
    include ActiveModel::Validations

    include Proxima::Attributes
    include Proxima::Paths
    include Proxima::Serialization
    include Proxima::Validation

    # TODO: Implement callbacks
    # extend  ActiveModel::Callbacks
    # define_model_callbacks :create, :update

    def self.api(api = nil)
      @api = api if api
      @api
    end

    def self.response
      @response
    end

    def self.responses
      @responses || []
    end

    def self.create(record)
      if record.is_a? Array
        models     = []
        @responses = []
        record.each do |record|
          model = self.create record
          @responses.push(model.response)
          models.push(model) if model
        end
        return models
      end

      model     = self.new(record)
      save_ok   = model.save
      @response = model.response

      return nil unless save_ok
      model
    end

    def self.find(query = {}, params = {}, opts = nil)

      # NOTE: This is a compatibility fix for 0.2 to 0.3
      if opts == nil
        opts   = params
        params = query
      end

      opts[:query] = self.convert_query_or_delta_to_json query
      @response    = self.api.get self.find_path.call(params), opts

      if @response.code != 200
        return []
      end

      models = self.from_json @response.body
      models.each { |model| model.new_record = false }
    end

    def self.find_one(query, params, opts = nil)
      query['$limit'] = 1
      self.find(query, params, opts)[0]
    end

    def self.count(query = {}, params = {}, opts = nil)

      # NOTE: This is a compatibility fix for 0.2 to 0.3
      if opts == nil
        opts   = params
        params = query
      end

      query['$limit'] = 0
      opts[:query]    = self.convert_query_or_delta_to_json query
      @response       = self.api.get self.find_path.call(params), opts

      return nil unless @response.code == 200

      @response.headers[:x_total_count] || 0
    end

    def self.find_by_id(id, params = {}, opts = {})
      params[:id] = id
      @response   = self.api.get self.find_by_id_path.call(params), opts

      return nil unless @response.code == 200

      model = self.new
      model.from_json @response.body
      model.new_record = false
      model
    end

    def initialize(record = {})
      self.new_record = true
      self.attributes = record
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

    def response
      @response
    end

    def save(options = {}, params = {})
      return false unless self.valid?

      if self.new_record?
        path      = self.class.create_path.call self.to_h
        payload   = { json: self.as_json(options) }
        @response = self.class.api.post path, payload

        return false unless @response.code == 201

        self.from_json @response.body, options[:include_root]
        self.new_record = false
        return true
      end

      return true if self.persisted?

      options[:flatten] = true if options[:flatten] == nil
      path      = self.class.update_by_id_path.call params.merge(self.to_h)
      payload   = { json: self.as_json(options) }
      @response = self.class.api.put path, payload

      return false unless @response.code == 204
      self.persisted = true
    end

    def reload!
      self.clear_changes_information
    end

    def rollback!
      self.restore_attributes
    end

    def destroy
      return false if new_record?

      @response = self.class.api.delete(self.class.delete_by_id_path.call(self.to_h))

      return false unless @response.code == 204
      self.persisted = true
    end

    def restore
      return false if new_record?

      @response = self.class.api.post(self.class.restore_by_id_path.call(self.to_h))

      return false unless @response.code == 204
      self.persisted = true
    end
  end
end
