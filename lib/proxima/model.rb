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

    def self.create(record)
      return record.map { |record| self.create record } if record.is_a? Array
      model = self.new(record)
      return nil unless model.save
      model
    end

    def self.find(query = {}, opts = {})
      opts[:query] = self.convert_query_or_delta_to_json query
      response     = self.api.get self.find_path.call(query), opts

      return [] unless response.code == 200

      records = ActiveSupport::JSON.decode response.body
      records.map do |record|
        model = self.new
        model.from_json record
        model.new_record = false
        model
      end
    end

    def self.find_one(query = {}, opts = {})
      query['$limit'] = 1;
      self.find(query, opts)[0]
    end

    def self.count(query = {}, opts = {})
      query['$limit'] = 0
      opts[:query]    = self.convert_query_or_delta_to_json query
      response        = self.api.get self.find_path.call(query), opts

      return nil unless response.code == 200

      response.headers[:x_total_count] || 0
    end

    def self.find_by_id(id, query = {}, opts = {})
      if opts == nil && query
        opts  = query
        query = {}
      end

      query[:id] = id
      response = self.api.get self.find_by_id_path.call(query), opts

      return nil unless response.code == 200

      model = self.new
      model.from_json response.body
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

    def save(options = {})
      return false unless self.valid?

      if self.new_record?
        path     = self.class.create_path.call self.to_h
        payload  = { json: self.as_json(options) }
        response = self.class.api.post path, payload

        return false unless response.code == 201

        self.from_json response.body, options[:include_root]
        self.new_record = false
        return true
      end

      return true if self.persisted?

      options[:flatten] = true if options[:flatten] == nil
      path     = self.class.update_by_id_path.call self.to_h
      payload  = { json: self.as_json(options) }
      response = self.class.api.put path, payload

      return false unless response.code == 204
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

      response = self.class.api.delete(self.class.delete_by_id_path.call(self.to_h))

      return false unless response.code == 204
      self.persisted = true
    end

    def restore
      return false if new_record?

      response = self.class.api.post(self.class.restore_by_id_path.call(self.to_h))

      return false unless response.code == 204
      self.persisted = true
    end
  end
end
