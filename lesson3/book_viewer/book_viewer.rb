require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'

before do
  @contents = File.readlines 'data/toc.txt'
end

get "/" do
  @contents = File.readlines 'data/toc.txt'
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  @title = "Chapter #{number}: #{@contents[number - 1]}"

  @chapter = File.read "data/chp#{number}.txt"
  @chapter = @chapter.split "\n\n"

  erb :chapter
end
