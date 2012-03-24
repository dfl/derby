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

post "/vote" do
  JSON.parse( params[:votes] ).each{|c| Vote.create(:contestant => c) }
  Vote.score.to_json
end

post "/reset" do
  protected!
  Vote.reset_all!
end