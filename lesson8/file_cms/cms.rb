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

def validate_filename
  filename = params[:filename]
  unless @files.include? filename
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
  filename
end

get '/:filename' do
  filename = validate_filename

  load_file_content "#{root}/data/#{filename}"
end

get '/:filename/edit' do
  filename = validate_filename

  @content = File.read "#{root}/data/#{filename}"
  erb :edit
end

post '/:filename' do
  filename = validate_filename

  content = params[:content]
  File.write "#{root}/data/#{filename}", content
  session[:message] = "#{filename} has been updated."
  redirect '/'
end
