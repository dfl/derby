require "bundler/setup"
require "sinatra"
require 'sinatra/activerecord'
require 'json'

set :database, ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/db/development.sqlite3"

require './models/vote'

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'dallas']
  end
end

get "/" do
  "OK"
end

get '/winner' do
  Vote.count > 2 ? Vote.winner : "no votes yet"
end

get '/score' do
  Vote.score_hash.to_s
end

post "/vote" do
  p params
  Vote.parse( params[:votes] )
  Vote.score_array.to_json
end

get "/reset" do
  protected!
  Vote.reset_all!
  redirect "/score"
end

get "/crossdomain.xml" do
    <<-XML
   <?xml version="1.0"?>
	    <!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
	    <cross-domain-policy>
	      <allow-access-from domain="home.earthlink.net" />
	    </cross-domain-policy> 
	  XML
end