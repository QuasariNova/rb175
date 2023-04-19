require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

before do
  @files = Dir.each_child('data/').to_a.sort
end

get '/' do
  erb :index
end
