class Api
  require 'faraday'

  attr_accessor :timeout
  attr_accessor :headers

  def initialize
    @timeout = 10
    @headers = nil
  end

  def get(url, params = nil)
    conn = connect(url)

    res = conn.get do |req|
      req.url url
      req.params = params if params
      req.headers = @headers if @headers
      req.options.timeout = @timeout
      req.options.open_timeout = 2
    end
  end

  def post(url, params = nil)
    conn = connect(url)

    res = conn.post do |req|
      req.url url
      req.body = params if params
      req.headers = @headers if @headers
      req.options.timeout = @timeout
      req.options.open_timeout = 2
    end
  end

  private

  # 汎用API通信メソッド
  def connect(url)
    Faraday::Connection.new(url: url) do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Adapter::NetHttp
    end
  end
end
