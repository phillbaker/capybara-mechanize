require 'mechanize'

class Capybara::Driver::Mechanize < Capybara::Driver::RackTest
  extend Forwardable
  
  def_delegator :agent, :scheme_handlers
  def_delegator :agent, :scheme_handlers=
  
  def initialize(app = nil)
    @agent = ::Mechanize.new
    @agent.redirect_ok = false
    
    if app
     # Delegate the RackApp to the RackTest driver
     super(app)
    elsif !Capybara.app_host
      raise ArgumentError, "You have to set at least Capybara.app_host or Capybara.app"
    end
  end
  
  def reset!
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
      process_remote_request(:get, url, params)
    else
      register_local_request
      super
    end
  end

  def post(url, params = {}, headers = {})
    if remote?(url)
      process_remote_request(:post, url, params, headers)
    else
      register_local_request
      super
    end
  end
  
  def put(url, params = {}, headers = {})
    if remote?(url)
      process_remote_request(:put, url)
    else
      register_local_request
      super
    end
  end

  def delete(url, params = {}, headers = {})
    if remote?(url)
      process_remote_request(:delete, url, params, headers)
    else
      register_local_request
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
      
      if host.nil? && last_request_remote?
        true
      else
        !(host.nil? || host.include?(Capybara.default_host))
      end
    end
  end

  attr_reader :agent

  private
  
  def last_request_remote?
    !!@last_request_remote
  end
  
  def register_local_request
    @last_remote_host = nil
    @last_request_remote = false
  end

  def process_remote_request(method, url, *options)
    if remote?(url)
      remote_uri = URI.parse(url)

      if remote_uri.host.nil?
        remote_host = @last_remote_host || Capybara.app_host || Capybara.default_host
        url = File.join(remote_host, url)
        url = "http://#{url}" unless url.include?("http")
      else
        @last_remote_host = "#{remote_uri.host}:#{remote_uri.port}"
      end
      
      reset_cache
      @agent.send *( [method, url] + options)
        
      @last_request_remote = true
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