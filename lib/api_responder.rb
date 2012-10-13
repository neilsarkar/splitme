module ApiResponder
  extend ActiveSupport::Concern

  class ApiError < StandardError; end
  class NotFoundError < ApiError; end
  class UnauthorizedError < ApiError; end

  included do
    before_filter :parse_post_body
    before_filter :set_access_control_headers
    layout false

    rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    rescue_from NotFoundError,                :with => :not_found
    rescue_from UnauthorizedError,            :with => :unauthorized
  end

  module InstanceMethods
    private

    def render_response(payload = nil, options = {})
      api_response = ApiResponse.new(payload, options)
      response.headers.merge!(options[:headers]) if options[:headers].present?
      render :json => api_response, :status => api_response.code
    end

    def render_error(code, errors = nil)
      errors = errors.full_messages if errors.respond_to?(:full_messages)
      api_response = ApiResponse.new(nil, :code => code, :errors => errors)
      render :json => api_response, :status => code
    end

    def not_found(exception)
      message = exception.is_a?(ActiveRecord::RecordNotFound) ?
        "The requested path does not exist" :
        exception.message

      render_error 404, message
    end

    def unauthorized(exception=nil)
      render_error 401, exception && exception.message
    end

    def forbidden(exception=nil)
      render_error 403, exception && exception.message
    end

    def parse_post_body
      return unless request.post? || request.put?
      body = request.body.read
      return if body.blank?
      begin
        json = Yajl::Parser.parse(body)
        params.merge!(json)
      rescue Yajl::ParseError
        # Fine, it's not JSON
      end
    end

    # Since we only allow authentication via a query string token parameter
    # this should be pretty safe. If an attacker has a token they could
    # make requests on the user's behalf without controlling their browser
    # anyway.
    def set_access_control_headers
      return unless request.headers["Origin"]
      response.headers["Access-Control-Allow-Origin"] = request.headers["Origin"]
      response.headers["Access-Control-Allow-Headers"] = 'Accept, Content-Type, X-Requested-With, X-Access-Token'
      response.headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      response.headers['Access-Control-Allow-Credentials'] = 'false'
      response.headers['Access-Control-Max-Age'] = '86400'
    end
  end

  class ApiResponse
    attr_accessor :code, :errors, :notifications

    def initialize(response, options = {})
      @response = response

      self.code          = options[:code] || 200
      self.errors        = options[:errors]
      self.notifications = options[:notifications]
    end

    def errors=(new_errors)
      @errors = new_errors.nil? ? [] : [new_errors].flatten
    end

    def notifications=(new_notifications)
      @notifications = new_notifications.nil? ? [] : [new_notifications].flatten
    end

    def as_json(options = {})
      hash = {
        "meta" => {
          "code" => code
        },
        "response" => @response
      }
      hash["meta"]["errors"] = errors if errors.any?
      hash["notifications"] = notifications if notifications.any?
      hash
    end

    def to_json(options = {})
      Yajl::Encoder.encode(as_json(options))
    end
  end
end
