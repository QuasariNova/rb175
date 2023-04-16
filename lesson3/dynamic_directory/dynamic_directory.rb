require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'

get '/' do
  @files = Dir.open('public') { |dir| dir.each_child.to_a.sort }
  erb :directory
end
