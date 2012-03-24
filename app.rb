require "bundler/setup"
require "sinatra"
require 'sinatra/activerecord'
require 'json'

set :database, ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/db/development.sqlite3"

require './models/vote'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  [username, password] == ['admin', 'dallas']
end

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
  end
end

get "/" do
  "OK"
end

get "/total" do
  Vote.total.to_json rescue "no votes yet"
end

post "/vote" do
  JSON.parse( params[:votes] ).each{|c| Vote.create(:contestant => c) }
  "OK"
end

post "/reset" do
  protected!
  Vote.reset_all!
end