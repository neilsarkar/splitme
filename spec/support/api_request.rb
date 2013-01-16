module ApiRequest
  def post(path, body={})
    @response = RestClient.post(
      "#{api_root}#{path}",
      Yajl::Encoder.encode(body),
      { content_type: :json, accept: :json }
    )

    parsed_response = Yajl::Parser.parse(@response)
    if parsed_response
      parsed_response["response"]
    else # e.g. head 200
      nil
    end
  rescue => error
    @response = WrappedError.new(error)
  end

  def get(path)
    @response = RestClient.get(
      "#{api_root}#{path}",
      { accept: :json }
    )
    Yajl::Parser.parse(@response)["response"]
  end

  def api_root
    return @api_root if defined?(@api_root)
    server = Capybara.current_session.driver.rack_server
    @api_root = "http://#{server.host}:#{server.port}/api"
  end

  class WrappedError
    def initialize(error)
      @error = error
      @json  = Yajl::Parser.parse(@error.http_body)
      @meta  = @json["meta"] if @json
    end

    def code
      @error.http_code
    end

    def [](key)
      if @json
        @json[key]
      else
        nil
      end
    end
  end
end

RSpec.configuration.include ApiRequest, example_group: {file_path: RSpec.configuration.escaped_path(%w[spec integration])}

