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

# Verifies if a list_name is valid. If not, it will render render_on_error,
# otherwise it executes the block passed to it.
def validate_list_name(list_name, render_on_error)
  if !(1..100).cover? list_name.size
    session[:error] = "List name must be between 1 and 100 characters"
  elsif session[:lists].any? { |list| list[:name] == list_name }
    session[:error] = "List name must be unique"
  end
  return erb render_on_error if session[:error]

  yield
end

# Create a new list
post '/lists' do
  list_name = params[:list_name].strip

  validate_list_name list_name, :new_list do
    session[:lists] << {name: list_name, todos: []}
    session[:success] = "The list has been created."
    redirect '/lists'
  end
end

# Checks if list_id is valid. If its not, it redirects, otherwise it runs the block
# passed to it.
def validate_list_id(id)
  unless (0...session[:lists].size).cover? id
    session[:error] = "List does not exist."
  end
  return redirect '/lists' if session[:error]

  yield
end

# Renders a todo list
get '/lists/:list_id' do
  list_id = params[:list_id].to_i
  validate_list_id list_id do
    @list = session[:lists][id]
    erb :list
  end
end

# Edit Existing Todo List
get '/lists/:list_id/edit' do
  list_id = params[:list_id].to_i
  validate_list_id list_id do
    @list = session[:lists][id]
    erb :edit_list
  end
end

# Update Existing Todo List
post '/lists/:list_id' do
  list_id = params[:list_id].to_i

  validate_list_id list_id do
    @list = session[:lists][id]
    list_name = params[:list_name].strip

    validate_list_name list_name, :edit_list do
      @list[:name] = list_name
      session[:success] = "The list has been updated."
      redirect "/lists/#{id}"
    end
  end
end

# Delete Existing Todo List
post '/lists/:list_id/delete' do
  list_id = params[:list_id].to_i

  validate_list_id list_id do
    session[:lists].delete_at id
    session[:success] = "The list has been removed."

    redirect '/lists'
  end
end

def validate_todo_name(todo_name)
  if !(1..100).cover? todo_name.size
    session[:error] = "Todo name must be between 1 and 100 characters"
  elsif @list[:todos].any? { |todo| todo[:name] == todo_name }
    session[:error] = "Todo name must be unique"
  end
  return erb :list if session[:error]

  yield
end
# Add Todo to List
post '/lists/:list_id/todos' do
  list_id = params[:list_id].to_i

  validate_list_id list_id do
    todo = params[:todo].strip
    @list = session[:lists][id]

    validate_todo_name todo do
      @list[:todos] << {name: todo, completed: false}
      session[:success] = "Todo added to list."

      redirect "/lists/#{id}"
    end
  end
end

def validate_todo_id(todo_id)
  unless (0...@list[:todos].size).cover? todo_id
    session[:error] = "Todo does not exist"
  end
  return erb :list if session[:error]

  yield
end

post '/lists/:list_id/todos/:todo_id/delete' do
  list_id = params[:list_id].to_i

  validate_list_id list_id do
    @list = session[:lists][id]
    todo_id = params[:todo_id].to_i

    validate_todo_id todo_id do
      @list[:todos].delete_at todo_id
      session[:success] = "The todo has been removed."
      redirect "/lists/#{params[:list_id]}"
    end
  end
end
