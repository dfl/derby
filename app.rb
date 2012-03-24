require "bundler/setup"
require "sinatra"

require './models/vote'

get "/" do
  "Hello world!"
end
