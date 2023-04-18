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

# Return an error message if the name is invalid. Return nil if name is valid
def list_name_error(list_name)
  if !(1..100).cover? list_name.size
    return "List name must be between 1 and 100 characters"
  elsif session[:lists].any? { |list| list[:name] == list_name }
    return "List name must be unique"
  end
end

# Create a new list
post '/lists' do
  list_name = params[:list_name].strip

  error = list_name_error(list_name)
  if error
    session[:error] = error
    erb :new_list
  else
    session[:lists] << {name: list_name, todos: []}
    session[:success] = "The list has been created."
    redirect '/lists'
  end
end

# Renders a todo list
get '/lists/:id' do
  @id = params[:id].to_i
  if @id >= session[:lists].size
    session[:error] = "List does not exist."
    redirect '/lists'
  elsif
    @list = session[:lists][@id]
    erb :list
  end
end
