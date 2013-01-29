require 'capybara/rack_test/driver'
require 'mechanize'

class Capybara::Mechanize::Browser < Capybara::RackTest::Browser
  extend Forwardable

  def_delegator :agent, :scheme_handlers
  def_delegator :agent, :scheme_handlers=

  def initialize(driver)
    @agent = ::Mechanize.new
    @agent.redirect_ok = false
    @agent.user_agent = default_user_agent
    super
  end

  def reset_host!
    @last_remote_uri = nil
    @last_request_remote = nil
    super
  end

  def current_url
    last_request_remote? ? remote_response.current_url : super
  end

  def last_response
    last_request_remote? ? remote_response : super
  end

  # process should be maintained as a direct copy of the base class's version with the addition of the marked line below
  def process(method, path, attributes = {})
    new_uri = URI.parse(path)
    current_uri = URI.parse(current_url)

    if new_uri.host
      @current_host = new_uri.scheme + '://' + new_uri.host

      # The process method has only been reimplemented in this derived class for this one line.
      # Note that this line is copied directly from capybara pre-2.0
      @current_host << ":#{new_uri.port}" if new_uri.port != new_uri.default_port
    end

    if new_uri.relative?
      if path.start_with?('?')
        path = request_path + path
      elsif not path.start_with?('/')
        path = request_path.sub(%r(/[^/]*$), '/') + path
      end
      path = current_host + path
    end

    reset_cache!
    send(method, path, attributes, env)
  end

  def process_without_redirect(method, path, attributes, headers)
    path = @last_path if path.nil? || path.empty?

    if remote?(path)
      process_remote_request(method, path, attributes, headers)
    else
      register_local_request

      send("racktest_#{method}", path, attributes, env.merge(headers))
    end

    @last_path = path
  end

  alias :racktest_get :get
  def get(path, attributes = {}, headers = {})
    process_without_redirect(:get, path, attributes, headers)
  end

  alias :racktest_post :post
  def post(path, attributes = {}, headers = {})
    process_without_redirect(:post, path, post_data(attributes), headers)
  end

  alias :racktest_put :put
  def put(path, attributes = {}, headers = {})
    process_without_redirect(:put, path, attributes, headers)
  end

  alias :racktest_delete :delete
  def delete(path, attributes = {}, headers = {})
    process_without_redirect(:delete, path, attributes, headers)
  end

  # Convert a deep hash of parameters recursively into a one-level
  # hash in the style of Rails where nested hashes become long keys
  # with secondary keys enclosed in square brackets.
  #
  # No attempt is make to prevent duplicate keys.  For example, if
  # there is a toplevel key of 'a[b][c]' and also an identical
  # expanded key, the value will be that of whichever was encountered
  # last according to the order of iteration through the hash
  # (i.e. unspecified).
  #
  # For example,
  #
  # {
  #   'a' => 1,
  #   'b' => {
  #            'c' => 1,
  #            'd' => { 'e' => 1, 'f' => 2 }
  #          }
  # }
  #
  # becomes
  #
  # {
  #   'a' => 1,
  #   'b[c]' => 1,
  #   'b[d][e]' => 1,
  #   'b[d][f]' => 2
  # }
  #
  # @param [Hash] params a possibly deep hash of parameters (with no
  # circular references).  Can also be an array of hashes in which
  # case the hashes will be effectively merged prior to conversion.
  #
  # @param [Proc] make_key a procedure for making the expanded key
  # given the key at this level
  #
  # @param [Hash] acc the hash with expanded keys
  def post_data(params, make_key = proc {|k| k}, acc = {})
    case params
    when Array
      params.each { |p| post_data(p, make_key, acc) }
      acc
    when Hash
      params.inject(acc) do |memo, keyval|
        key, val = keyval
        
        case val
        when Hash
          post_data(val,
                    proc { |k| "#{make_key.call(key)}[#{k}]" },
                    memo)
        else
          memo[make_key.call(key)] = val
        end
        memo
      end
    end
  end

  def remote?(url)
    if Capybara.app_host
      true
    else
      host = URI.parse(url).host

      if host.nil?
        last_request_remote?
      else
        !Capybara::Mechanize.local_hosts.include?(host)
      end
    end
  end

  attr_reader :agent

  private

  def last_request_remote?
    !!@last_request_remote
  end

  def register_local_request
    @last_remote_uri = nil
    @last_request_remote = false
  end

  def remote_request_path
    @last_remote_uri.nil? ? nil : @last_remote_uri.path
  end

  def request_path
    last_request_remote? ? remote_request_path : super
  end

  def process_remote_request(method, url, attributes, headers)
    if remote?(url)
      uri = URI.parse(url)
      @last_remote_uri = uri
      url = uri.to_s

      reset_cache!
      begin
        args = []
        args << attributes unless attributes.empty?
        args << headers unless headers.empty?
        @agent.send(method, url, *args)
      rescue => e
        raise "Received the following error for a #{method.to_s.upcase} request to #{url}: '#{e.message}'"
      end
      @last_request_remote = true
    end
  end

  def remote_response
    ResponseProxy.new(@agent.current_page) if @agent.current_page
  end

  def default_user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.853.0 Safari/535.2"
  end

  class ResponseProxy
    extend Forwardable

    def_delegator :page, :body

    attr_reader :page

    def initialize(page)
      @page = page
    end

    def current_url
      page.uri.to_s
    end

    def headers
      # Hax the content-type contains utf8, so Capybara specs are failing, need to ask mailinglist
      headers = page.response
      headers["content-type"].gsub!(';charset=utf-8', '') if headers["content-type"]
      headers
    end

    def [](key)
      headers[key]
    end

    def status
      page.code.to_i
    end

    def redirect?
      status >= 300 && status < 400
    end

  end

end

