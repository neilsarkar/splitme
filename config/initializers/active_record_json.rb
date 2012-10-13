class ActiveRecord::Base
  def to_json(*)
    Yajl::Encoder.encode(as_json)
  end
end
