require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secretsecretsecretsecretsecretsecretsecretsecretsecretsecretsecr'
end

before do
  session[:lists] ||= []
end

get '/' do
  redirect "/lists"
end

# View list of lists
get '/lists' do
  @lists = session[:lists]
  erb :lists
end

# Render the new list form
get '/lists/new' do
  erb :new_list
end

# Create a new list
post '/lists' do
  session[:lists] << {name: params[:list_name], todos: []}
  session[:success] = "The list has been created."
  redirect '/lists'
end