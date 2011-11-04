require 'capybara/spec/test_app'

class ExtendedTestApp < TestApp#< Sinatra::Base
  set :environment, :production # so we don't get debug info that makes our test pass!

  get %r{/redirect_to/(.*)} do
    redirect params[:captures]
  end

  get '/form_with_relative_action_to_host' do
    %{<form action="/request_info/host" method="post">
       <input type="submit" value="submit" />
      </form>}
  end

  get '/form_with_fancy_params' do
    %{<form action="/params" method="post">
       <input id="cart_line_items__product_id" name="cart[line_items][][product_id]" value="2">
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

  post '/params' do
    begin
      # The problem is the form is posted like:
      # {"cart"=>{"line_items"=>"[{\"product_id\"=>\"2\"}]"}}
      # Note that the array is wrapped in a string.
      # I couldn't get this to happen in the mechanize
      # project, so I'm assuming it's a capybara bug.
      puts params
      "first product id is #{ params["cart"]["line_items"].first["product_id"] }"
    rescue
      puts $!.message
      puts $!.backtrace
      raise
    end
  end

  post '/request_info/*' do
    current_request_info
  end


  private

    def current_request_info
      "Current host is #{request.url}, method #{request.request_method.downcase}"
    end
end
