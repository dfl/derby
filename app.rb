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

  def blacklisted_ip?
    # "75.6.249.153" David Warczak
    blocked = [ "108.57.32.181", "76.249.234.217", "24.242.202.58", "208.114.151.167"]
    blocked.include?( request.ip )
  end
  
  def too_many? klass, max=5
    conditions = ["created_at > ? AND ip = ?", 1.day.ago, request.ip]
    case klass
    when Vote, :votes
      Vote.where( conditions ).group("contestant_id")
    when QuestionVote, :question_votes
      QuestionVote.where( conditions ).group("question_id")
    end.count.values.any?{|c| c > max}
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
  if blacklisted_ip?
    puts "attempt from blacklisted #{request.ip}"
  elsif too_many?( Vote )
    puts "attempt from blocked #{request.ip}"    
  else
    Vote.parse( params[:votes], request.ip )
  end
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
  if blacklisted_ip?
    puts "attempt from blacklisted #{request.ip}"
  elsif too_many?( QuestionVote )
    puts "attempt from blocked #{request.ip}"
  else
    QuestionVote.parse( params[:votes], request.ip )
  end
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