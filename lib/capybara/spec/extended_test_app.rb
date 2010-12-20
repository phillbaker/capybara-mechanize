require 'capybara/spec/test_app'

class ExtendedTestApp < TestApp#< Sinatra::Base
  set :environment, :production # so we don't get debug info that makes our test pass!

  get %r{/redirect_to/(.*)} do
    redirect params[:captures]
  end

  get '/host' do
    "current host is #{request.host}:#{request.port}, method get"
  end

  get '/form_with_relative_action_to_host' do
    %{<form action="/host" method="post">
       <input type="submit" value="submit" />
      </form>}
  end

  get '/relative_link_to_host' do
    %{<a href="/host">host</a>}
  end

  post '/host' do
    "current host is #{request.host}:#{request.port}, method post"
  end
end

if __FILE__ == $0
  Rack::Handler::Mongrel.run ExtendedTestApp, :Port => 8070
end


