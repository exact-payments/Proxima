require "proxima/version"
require "proxima/api"
require "proxima/model"


module Proxima

  @types = [
    {
      klass:     String,
      from_json: -> v { v.to_s },
      to_json:   -> v { v.to_s }
    }, {
      klass:     Integer,
      from_json: -> v { v.to_i },
      to_json:   -> v { v.to_i }
    }, {
      klass:     Float,
      from_json: -> v { v.to_f },
      to_json:   -> v { v.to_f }
    }, {
      klass:     Rational,
      from_json: -> v { v.to_r },
      to_json:   -> v { v.to_r }
    }, {
      klass:     Complex,
      from_json: -> v { v.to_c },
      to_json:   -> v { v.to_c }
    }, {
      klass:     TrueClass,
      from_json: -> v { v.to_s == 'true' },
      to_json:   -> v { v.to_s == 'true' }
    }, {
      klass:     Array,
      from_json: -> v { v.to_a },
      to_json:   -> v { v.to_a }
    }, {
      klass:     Hash,
      from_json: -> v { v.to_h },
      to_json:   -> v { v.to_h }
    }, {
      klass:     DateTime,
      from_json: -> v { DateTime.iso8601 v },
      to_json:   -> v { v.iso8601 3 }
    }
  ]

  def self.add_type(klass, from = nil, to = nil)
    @types.push({
      klass: klass,
      from:  from,
      to:    to
    })
  end

  def self.remove_type(klass)
    @types.delete_if({
      klass: klass,
      from:  from,
      to:    to
    })
  end

  def self.type_from_json(klass, value)
    type = @types.find { |t| t[:klass] == klass }
    type.from_json(value) if type else value
  end

  def self.type_to_json(klass, value)
    type = @types.find { |t| t[:klass] == klass }
    type.to_json(value) if type else value
  end
end
