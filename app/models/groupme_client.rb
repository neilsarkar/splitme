class GroupmeClient
  def initialize(token = nil)
    @token = token
    @base_url = GROUPME_API_URL
  end

  def get(path)
    path = "/#{path}" unless path[0] == "/"
    path += "?token=#{@token}" if @token
    Response.new(Faraday.get(@base_url + path))
  end

  class Response
    attr_reader :status_code, :errors, :response

    def initialize(faraday_response)
      @status_code = faraday_response.status
      parse_response(faraday_response) if faraday_response.body.present?
    end

    def success?
      @status_code >= 200 && @status_code < 300
    end

    alias_method :status, :status_code

    private

    def parse_response(faraday_response)
      json = Yajl::Parser.parse(faraday_response.body)
      if success?
        if json["response"].is_a? Hash
          @response = HashWithIndifferentAccess.new(json["response"])
        else
          @response = json["response"]
        end
      else
        if json["meta"]["errors"].is_a? Hash
          @errors = HashWithIndifferentAccess.new(json["meta"]["errors"])
        else
          @errors = json["meta"]["errors"]
        end
      end
    end
  end
end
