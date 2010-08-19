require 'mechanize'

class Capybara::Driver::Mechanize < Capybara::Driver::RackTest
  extend Forwardable
  
  def_delegator :agent, :scheme_handlers
  def_delegator :agent, :scheme_handlers=
  
  def initialize(*args)
    super
    @agent = ::Mechanize.new
    @agent.redirect_ok = false
  end
  
  def cleanup!
    @agent.cookie_jar.clear!
    super
  end
  
  def current_url
    last_request_remote? ? remote_response.current_url : super
  end
  
  def response
    last_request_remote? ? remote_response : super
  end
  
  # TODO see how this can be cleaned up
  def follow_redirect!
    unless response.redirect?
      raise "Last response was not a redirect. Cannot follow_redirect!"
    end
    
    location = if last_request_remote?
        remote_response.page.response['Location'] 
      else
        response['Location']
      end
    
    get(location)
  end
  
  def get(url, params = {}, headers = {})
    if remote?(url)
      process_remote_request(:get, url)
    else 
      super
    end
  end

  def post(url, params = {}, headers = {})
    if remote?(url)
      process_remote_request(:post, url, params, headers)
    else 
      super
    end
  end

  def remote?(url)
    if !Capybara.app_host.nil? 
      true
    elsif Capybara.default_host.nil?
      false
    else
      host = URI.parse(url).host
      !(host.nil? || host.include?(Capybara.default_host))
    end
  end

  attr_reader :agent

  private
  
  def last_request_remote?
    !!@last_request_remote
  end

  def process_remote_request(method, url, *options)
    if remote?(url)
      url = File.join((Capybara.app_host || Capybara.default_host), url) if URI.parse(url).host.nil?
      reset_cache
      @agent.send *( [method, url] + options)
      @last_request_remote = true
    else
      @last_request_remote = false
    end
  end

  def remote_response
    ResponseProxy.new(@agent.current_page) if @agent.current_page
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
      page.response
    end

    def status
      page.code.to_i
    end    

    def redirect?
      [301, 302].include?(status)
    end
    
  end 
   
end