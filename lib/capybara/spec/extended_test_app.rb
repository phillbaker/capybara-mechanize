require 'capybara/spec/test_app'

class ExtendedTestApp < TestApp
  set :environment, :production # so we don't get debug info that makes our test pass!
  disable :protection

  get %r{/redirect_to/(.*)} do
    redirect params[:captures].first
  end

  get '/form_with_relative_action_to_host' do
    %{<form action="/request_info/host" method="post">
       <input type="submit" value="submit" />
      </form>}
  end

  get '/request_info/form_with_no_action' do
    %{<form method="post">
       <input type="submit" value="submit" />
      </form>}
  end

  get '/relative_link_to_host' do
    %{<a href="/request_info/host">host</a>}
  end

  get '/request_info/user_agent' do
    request.user_agent
  end

  get '/request_info/*' do
    current_request_info
  end

  post '/request_info/*' do
    current_request_info
  end

  get '/subsite/relative_link_to_host' do
    %{<a href="/subsite/request_info2/host">host</a>}
  end

  get '/subsite/local_link_to_host' do
    %{<a href="request_info2/host">host</a>}
  end

  get '/subsite/request_info2/*' do
    "subsite: " + current_request_info
  end

  get '/redirect_with_http_param' do
    redirect '/redirect_target?foo=http'
  end

  get '/redirect_target' do
    %{correct redirect}
  end

  get %r{/form_posts_to/(.*)} do
    %{
      <form action="#{params[:captures].first}" method="post">
        <input type="submit" value="submit" />
      </form>
    }
  end

  post '/get_referer' do
    request.referer.nil? ? "No referer" : "Got referer: #{request.referer}"
  end

  private

    def current_request_info
      "Current host is #{request.url}, method #{request.request_method.downcase}"
    end
end

