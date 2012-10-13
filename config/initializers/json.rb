ActiveSupport::JSON.backend = "Yajl"
require 'yajl/json_gem'

class NilClass
  def as_json(*)
    nil
  end

  def encode_json(*)
    "null"
  end
end

ActiveRecord::Base.include_root_in_json = false
