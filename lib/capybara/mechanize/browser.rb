require 'capybara/rack_test/driver'
require 'mechanize'
require 'capybara/mechanize/node'
require 'capybara/mechanize/form'

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
    @errored_remote_response = nil
    super
  end

  def current_url
    last_request_remote? ? remote_response.current_url : super
  end

  def last_response
    last_request_remote? ? remote_response : super
  end

  def last_request
    last_request_remote? ? OpenStruct.new(request_method: @last_method, params: @last_params) : super
  end

  # For each of these http methods, we want to intercept the method call.
  # Then we determine if the call is remote or local.
  # Remote: Handle it with our process_remote_request method.
  # Local: Register the local request and call super to let RackTest get it.
  [:get, :post, :put, :delete].each do |method|
    define_method(method) do |path, params = {}, env = {}, &block|
      path = @last_path if path.nil? || path.empty?

      if remote?(path)
        process_remote_request(method, path, params, env, &block)
      else
        register_local_request
        super(path, params, env, &block)
      end

      @last_path = path
      @last_method = method
      @last_params = params
      @last_env = env
    end
  end

  def refresh
    if last_request_remote?
      process_remote_request(@last_method, @last_remote_uri.to_s, @last_params, @last_env)
    else
      register_local_request
      super
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

  def find(format, selector)
    if format==:css
      dom.css(selector, Capybara::RackTest::CSSHandlers.new)
    else
      dom.xpath(selector)
    end.map { |node| Capybara::Mechanize::Node.new(self, node) }
  end

  attr_reader :agent, :errored_remote_response

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
        if method == :post
          if attributes.is_a? Mechanize::Form
            submit_mechanize_form(url, attributes, headers)
          else
            @agent.send(method, url, attributes, headers)
          end
        elsif method == :get
          if attributes.is_a? Mechanize::Form
            submit_mechanize_form(url, attributes, headers)
          else
            referer = headers['HTTP_REFERER']
            @agent.send(method, url, attributes, referer, headers)
          end
        else
          @agent.send(method, url, attributes, headers)
        end
        @errored_remote_response = nil
      rescue Mechanize::ResponseCodeError => e
        @errored_remote_response = e.page

        if Capybara.raise_server_errors
          raise "Received the following error for a #{method.to_s.upcase} request to #{url}: '#{e.message}'"
        end
      end
      @last_request_remote = true
    end
  end

  def submit_mechanize_form(url, form, headers)
    form.action = url
    @agent.submit(form, nil, headers)
  end

  def remote_response
    if errored_remote_response
      ResponseProxy.new(errored_remote_response)
    elsif @agent.current_page
      ResponseProxy.new(@agent.current_page)
    end
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

