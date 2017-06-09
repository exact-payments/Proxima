
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

    include Proxima::HTTPMethods
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

    def self.create(record, params = {}, opts = {})
      if record.is_a? Array
        models     = []
        @responses = []
        record.each do |record|
          model = self.create record
          @responses.push model.response
          models.push(model) if model
        end
        return models
      end

      model     = self.new record
      save_ok   = model.save params, opts
      @response = model.response

      return nil unless save_ok
      model
    end

    def self.find(query = {}, params = {}, opts = {})
      opts[:query] = self.convert_query_or_delta_to_json query
      @response    = self.api.get self.find_path.call(params.merge(query)), opts

      return [] unless @response.code == 200

      self.from_json @response.body
    end

    def self.count_and_find(query = {}, params = {}, opts = {})
      items       = self.find query, params, opts
      total_count = self.response.headers[:x_total_count].to_i || 0

      Struct.new(:total_count, :items).new(total_count, items)
    end

    def self.find_one(query = {}, params = {}, opts = {})
      query['$limit'] = 1
      self.find(query, params, opts)[0]
    end

    def self.count(query = {}, params = {}, opts = {})
      query['$limit'] = 0
      opts[:query]    = self.convert_query_or_delta_to_json query
      @response       = self.api.get self.find_path.call(params), opts

      return nil unless @response.code == 200

      @response.headers[:x_total_count] || 0
    end

    def self.find_by_id(id, params = {}, opts = {})
      raise "id cannot be blank" if id.blank?
      params[:id] = id
      @response   = self.api.get self.find_by_id_path.call(params), opts

      return nil unless @response.code == 200

      self.from_json @response.body, single_model_from_array: true
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

    def save(params = {}, opts = {})
      return false unless self.valid?

      if self.new_record?
        path      = self.class.create_path.call self.to_h.merge(params)
        payload   = { json: self.as_json(opts) }
        @response = self.class.api.post path, payload

        return false unless @response.code == 201

        self.from_json @response.body, opts
        self.new_record = false
        return true
      end

      return true if self.persisted?

      opts[:flatten] = true if opts[:flatten] == nil
      path      = self.class.update_by_id_path.call self.to_h.merge(params)
      payload   = { json: self.as_json(opts) }
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
      raise "Cannot destroy a new record" if new_record?

      @response = self.class.api.delete(self.class.delete_by_id_path.call(self.to_h))

      return false unless @response.code == 204
      self.persisted = true
    end

    def restore
      raise "Cannot restore a new record" if new_record?

      @response = self.class.api.post(self.class.restore_by_id_path.call(self.to_h))

      return false unless @response.code == 204
      self.persisted = true
    end
  end
end
