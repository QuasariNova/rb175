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

  erb :chapter
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map do |paragraph|
      "<p>#{paragraph}</p>"
    end.join "\n\n"
  end
end
