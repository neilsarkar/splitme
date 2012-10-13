module JsonHelper
  def post(action, parameters = nil, session = nil, flash = nil)
    if parameters.is_a?(Hash) && parameters[:json].present?
      json_params = parameters.delete(:json)
      request.env["RAW_POST_DATA"] = json_params.to_json
      super(action, parameters, session, flash)
      request.env.delete("RAW_POST_DATA")
      response
    else
      super
    end
  end

  def json
    if @last_response.nil? || @last_response != response
      @last_response = response
      @last_json = Yajl::Parser.parse(response.body)
    else
      @last_json
    end
  end
end

RSpec::Rails::ControllerExampleGroup.send(:include, JsonHelper)
