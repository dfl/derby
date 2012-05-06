require "bundler/setup"
require "sinatra"
require 'sinatra/activerecord'
require 'json'


dbconfig = YAML.load(File.read("config/database.yml"))
RACK_ENV ||= ENV["RACK_ENV"] || "development"
ActiveRecord::Base.establish_connection dbconfig[RACK_ENV]
ActiveRecord::Base.logger = Logger.new(File.open("log/#{RACK_ENV}.log", "a"))
#set :database, ENV["DATABASE_URL"] || "sqlite3:///#{Dir.pwd}/db/development.sqlite3"

require './models/vote'
require './models/question_vote'

helpers do
  def protected!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end

  def blocked_ip?
    blocked = [ "108.57.32.181" ]
    blocked.include? request.ip
  end
  
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'dallas']
  end
end

get "/" do
  "OK"
end

post "/vote" do
  p params
  Vote.parse( params[:votes] ) unless blocked_ip?
  Vote.score_array.join(",")
end

get '/score' do
  Vote.score_hash.to_s
end

get '/winner' do
  Vote.count > 2 ? Vote.winner_to_s : "no votes yet"
end



get "/reset" do
  protected!
  Vote.reset_all!
  redirect "/score"
end


post "/question/vote" do
  p params
  QuestionVote.parse( params[:votes] ) unless blocked_ip?
  QuestionVote.score_array.join(",")
end

get '/question/score' do
  QuestionVote.score_hash.to_s
end

get '/question/winner' do
  QuestionVote.count > 2 ? QuestionVote.winner_to_s : "no votes yet"
end

get "/question/reset" do
  protected!
  QuestionVote.reset_all!
  redirect "/question/score"
end


get "/crossdomain.xml" do
    <<-XML
   <?xml version="1.0"?>
	    <!DOCTYPE cross-domain-policy SYSTEM "http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd">
	    <cross-domain-policy>
	      <allow-access-from domain="dallasdivasderby.com" />
	      <allow-access-from domain="www.dallasdivasderby.com" />
	      <allow-access-from domain="home.earthlink.net" />
	    </cross-domain-policy> 
	  XML
end