require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "redcarpet"

require_relative 'libs/sinatra/cms_helpers'

def data_path
  if ENV["RACK_ENV"] == "test"
    return File.expand_path '../test/data', __FILE__
  end
  File.expand_path '../data', __FILE__
end

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

get '/new' do
  require_signed_in_user
  erb :new
end

get '/:filename' do
  filename = validate_filename

  load_file_content "#{data_path}/#{filename}"
end

get '/:filename/edit' do
  filename = validate_filename
  require_signed_in_user

  @content = File.read "#{data_path}/#{filename}"
  erb :edit
end

post '/create' do
  require_signed_in_user
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
  status 422
  erb :new
end

post '/:filename' do
  filename = params[:filename]
  require_signed_in_user

  content = params[:content]
  File.write "#{data_path}/#{filename}", content
  session[:message] = "#{filename} has been updated."
  redirect '/'
end

post '/:filename/delete' do
  filename = validate_filename
  require_signed_in_user

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
  unless authenticate_user? @username, params['password']
    status 422
    session[:message] = 'Invalid credentials.'
    return erb :signin
  end

  session[:message] = 'Welcome!'
  session[:username] = @username
  redirect '/'
end

post '/users/signout' do
  session.delete :username
  session[:message] = 'You have been signed out.'
  redirect '/'
end
