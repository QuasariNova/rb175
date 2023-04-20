require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

root = File.expand_path "..", __FILE__

configure do
  enable :sessions
  set :session_secret,
      'secretsecretsecretsecretsecretsecretsecretsecretsecretsecretsecr'
end

before do
  @files = Dir.each_child("#{root}/data/").to_a.sort
end

get '/' do
  erb :index
end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML
  markdown.render text
end

def load_file_content(path)
  content = File.read path
  case File.extname(path)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content
  when '.md'
    render_markdown content
  end
end

get '/:filename' do
  file_name = params[:filename]
  unless @files.include? file_name
    session[:error] = "#{file_name} does not exist."
    redirect '/'
  end

  load_file_content "#{root}/data/#{file_name}"
end
