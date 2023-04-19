require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

root = File.expand_path "..", __FILE__

before do
  @files = Dir.each_child("#{root}/data/").to_a.sort
end

get '/' do
  erb :index
end

get '/:filename' do
  file_name = params[:filename]
  redirect '/' unless @files.include? file_name

  headers['Content-Type'] = 'text/plain'
  File.read "#{root}/data/#{file_name}"
end
