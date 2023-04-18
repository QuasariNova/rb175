require "sinatra"
require "sinatra/content_for"
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

def verify_list_name(list_name)
  if !(1..100).cover? list_name.size
    session[:error] = "List name must be between 1 and 100 characters"
  elsif session[:lists].any? { |list| list[:name] == list_name }
    session[:error] = "List name must be unique"
  end
  success = !session[:error]

  puts session[:error]
  yield success
end

# Create a new list
post '/lists' do
  list_name = params[:list_name].strip

  verify_list_name list_name do |success|
    return erb :new_list unless success

    session[:lists] << {name: list_name, todos: []}
    session[:success] = "The list has been created."
    redirect '/lists'
  end
end

def verify_id(id)
  unless (0...session[:lists].size).cover? id
    session[:error] = "List does not exist."
  end
  success = !session[:error]

  yield success
end

# Renders a todo list
get '/lists/:id' do
  id = params[:id].to_i
  verify_id id do |success|
    return redirect '/lists' unless success

    @list = session[:lists][id]
    erb :list
  end
end

# Edit Existing Todo List
get '/lists/:id/edit' do
  id = params[:id].to_i
  verify_id id do |success|
    return redirect '/lists' unless success

    @list = session[:lists][id]
    erb :edit_list
  end
end

# Update Existing Todo List
post '/lists/:id' do
  id = params[:id].to_i

  verify_id id do |success|
    return redirect '/lists' unless success

    @list = session[:lists][id]
    list_name = params[:list_name].strip
    verify_list_name list_name do |success|
      return erb :edit_list unless  success

      @list[:name] = list_name
      session[:success] = "The list has been updated."
      redirect "/lists/#{id}"
    end
  end
end

# Delete Existing Todo List
post '/lists/:id/delete' do
  id = params[:id].to_i

  verify_id id do |success|
    if success
      session[:lists].delete_at id
      session[:success] = "The list has been removed."
    end

    redirect "/lists"
  end
end
