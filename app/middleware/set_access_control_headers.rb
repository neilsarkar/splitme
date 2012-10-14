class SetAccessControlHeaders
  ALLOWED_HEADERS = %w[
    Accept
    Content-Type
    X-Requested-With
    X-Access-Token
    User-Agent
    Pragma
    Referrer
    Cache-Control
    Origin
  ]

  def initialize(app)
    @app = app
  end

  def call(env)
    if env["REQUEST_METHOD"] == "OPTIONS"
      headers = {
        "Access-Control-Allow-Origin" => env["HTTP_ORIGIN"],
        "Access-Control-Allow-Headers" => ALLOWED_HEADERS.join(', '),
        "Access-Control-Allow-Methods" => 'POST, GET, OPTIONS',
        "Access-Control-Allow-Credentials" => 'false',
        "Access-Control-Max-Age" => "86400"
      }
      [200, headers, []]
    else
      @app.call(env)
    end
  end
end
