require 'mechanize'

class Capybara::Driver::Mechanize < Capybara::Driver::RackTest
  
  def initialize(*args)
    super
    @agent = ::Mechanize.new
  end
  
  def visit(url)
    get url
  end
  
  def response
    response_proxy || super
  end
  
  def get(url, params = {}, headers = {})
    process_remote_request(:get, url) || super
  end

  def post(url, params = {}, headers = {})
    process_remote_request(:post, url, params, headers) || super
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

  private

  def process_remote_request(method, url, *options)
    if remote?(url)
      reset_cache
      @agent.send *( [method, url] + options)
      follow_redirects!
      true
    end
  end

  def response_proxy
    ResponseProxy.new(@agent.current_page) if @agent.current_page
  end
  
  class ResponseProxy
    def initialize(page)
      @page = page
    end
    
    def redirect?
      %w(301 302).include?(@page.code)
    end
    
    def method_missing(method, *args, &block)
      @page.send(method, *args, &block)
    end
    
  end 
   
end