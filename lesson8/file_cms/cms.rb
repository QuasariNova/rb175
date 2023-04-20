require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

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

get '/:filename' do
  file_name = params[:filename]
  unless @files.include? file_name
    session[:error] = "#{file_name} does not exist."
    redirect '/'
  end

  headers['Content-Type'] = 'text/plain'
  File.read "#{root}/data/#{file_name}"
end
