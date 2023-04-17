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

  redirect '/' unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{@contents[number - 1]}"
  @chapter = File.read "data/chp#{number}.txt"

  erb :chapter
end

get "/search" do
  @results = chapters_matching params['query']

  erb :search
end

not_found do
  redirect '/'
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |paragraph, idx|
      "<p id='par#{idx + 1}'>#{paragraph}</p>"
    end.join "\n\n"
  end

  def highlight(text, term)
    text.gsub term, "<strong>#{term}</strong>"
  end
end

def each_chapter
  @contents.each_with_index do |name, index|
    number = index + 1
    contents = File.read("data/chp#{number}.txt")
    yield number, name, contents
  end
end

def chapters_matching(query)
  return nil if !query || query.empty?
  results = []
  query = Regexp.new query

  each_chapter do |number, name, contents|
    matches = []

    contents.split("\n\n").each_with_index do |paragraph, idx|
      next unless paragraph =~ query
      matches << { id: "par#{idx + 1}", content: paragraph}
    end

    next unless matches.any?
    results << { number: number, name: name, paragraphs: matches }
  end

  results
end
