require 'proxima/watch/hash'
require 'proxima/watch/array'

module Proxima

  def watch(val, &block)
    Proxima.watch_hash(value, &block)  if value.is_a?(Hash)
    Proxima.watch_array(value, &block) if value.is_a?(Array)
  end
end
