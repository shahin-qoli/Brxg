Spree::Core::Engine.add_routes do
  get '/bankpayment/:reqid/:payid/:type', :to => "brx#getandverify", :as => :get_verify
  get '/paymenturl/:orderid/:amount', :to => 'brx#geturl', :as => :get_url
end

