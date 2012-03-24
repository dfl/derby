require "bundler/setup"
require "sinatra"
require 'sinatra/activerecord'
require 'json'

set :database, ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/db/development.sqlite3"

require './models/vote'

# use Rack::Auth::Basic, "Restricted Area" do |username, password|
#   [username, password] == ['admin', 'admin']
# end

get "/" do
  "OK"
end

get "/total" do
  Vote.total.to_json
end

post "/vote" do
  JSON.parse( params[:votes] ).each{|c| Vote.create(:contestant => c) }
  "OK"
end

post "/reset" do
  Vote.reset_all! #if params[:password]="dallas"
end