require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

# rubocop:disable Style::ExpandPathArguments
def data_path
  if ENV["RACK_ENV"] == "test"
    return File.expand_path '../test/data', __FILE__
  end
  File.expand_path '../data', __FILE__
end
# rubocop:enable Style::ExpandPathArguments

configure do
  enable :sessions
  set :session_secret,
      'secretsecretsecretsecretsecretsecretsecretsecretsecretsecretsecr'
end

before do
  @files = Dir.each_child(data_path).to_a.sort
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
  case File.extname path
  when '.md'
    erb render_markdown(content)
  else
    headers['Content-Type'] = 'text/plain'
    content
  end
end

def validate_filename
  filename = params[:filename]
  filepath = File.join data_path, filename

  unless File.exist? filepath
    session[:message] = "#{filename} does not exist."
    redirect '/'
  end
  filename
end

get '/new' do
  erb :new
end

get '/:filename' do
  filename = validate_filename

  load_file_content "#{data_path}/#{filename}"
end

get '/:filename/edit' do
  filename = validate_filename

  @content = File.read "#{data_path}/#{filename}"
  erb :edit
end

post '/create' do
  filename = params[:filename].strip

  case filename
  when ''
    session[:message] = 'A name is required.'
  when 'new'
    session[:message] = "'new' is not a valid name."
  when 'create'
    session[:message] = "'create' is not a valid name."
  else
    File.write "#{data_path}/#{filename}", ''
    session[:message] = "#{filename} was created."
    redirect '/'
  end
  erb :new
end

post '/:filename' do
  filename = params[:filename]

  content = params[:content]
  File.write "#{data_path}/#{filename}", content
  session[:message] = "#{filename} has been updated."
  redirect '/'
end

post '/:filename/delete' do
  filename = validate_filename
  FileUtils.remove_file File.join data_path, filename
  session[:message] = "#{filename} has been deleted."
  redirect '/'
end

get '/users/signin' do
  redirect '/' if session[:username]
  erb :signin
end

post '/users/signin' do
  redirect '/' if session[:username]

  @username = params['username']
  password = params['password']
  unless @username == 'admin' && password == 'secret'
    status 422
    session[:message] = 'Invalid credentials.'
    return erb :signin
  end

  session[:message] = 'Welcome'
  session[:username] = @username
  redirect '/'
end

post '/users/signout' do
  session.delete :username
  session[:message] = 'You have been signed out.'
  redirect '/'
end
