require "sinatra"
require "sinatra/content_for"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret,
      'secretsecretsecretsecretsecretsecretsecretsecretsecretsecretsecr'
  set :erb, :escape_html => true
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
def validate_list_name(render_on_error=:new_list)
  list_name = params[:list_name].strip

  if !(1..100).cover? list_name.size
    session[:error] = "List name must be between 1 and 100 characters"
  elsif session[:lists].any? { |list| list[:name] == list_name }
    session[:error] = "List name must be unique"
  end
  return erb render_on_error if session[:error]

  yield list_name
end

# Create a new list
post '/lists' do
  list_name = params[:list_name].strip

  validate_list_name do |list_name|
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = "The list has been created."
    redirect '/lists'
  end
end

# Checks if list_id is valid. If its not, it redirects, otherwise it runs the
# block passed to it.
def validate_list
  list_id = params[:list_id].to_i

  unless (0...session[:lists].size).cover? list_id
    session[:error] = "List does not exist."
    return redirect '/lists'
  end

  @list = session[:lists][list_id]
  yield list_id
end

# Renders a todo list
get '/lists/:list_id' do
  validate_list do
    erb :list
  end
end

# Edit Existing Todo List
get '/lists/:list_id/edit' do
  validate_list do
    erb :edit_list
  end
end

# Update Existing Todo List
post '/lists/:list_id' do
  validate_list do |list_id|
    validate_list_name :edit_list do |list_name|
      @list[:name] = list_name
      session[:success] = "The list has been updated."
      redirect "/lists/#{list_id}"
    end
  end
end

# Delete Existing Todo List
post '/lists/:list_id/delete' do
  validate_list do |list_id|
    session[:lists].delete_at list_id
    session[:success] = "The list has been removed."

    redirect '/lists'
  end
end

# Checks if a todo_name is valid for @list. Renders the :list view if not,
# otherwise yields to the given block
def validate_todo_name
  todo_name = params[:todo].strip

  if !(1..100).cover? todo_name.size
    session[:error] = "Todo name must be between 1 and 100 characters"
  elsif @list[:todos].any? { |todo| todo[:name] == todo_name }
    session[:error] = "Todo name must be unique"
  end
  return erb :list if session[:error]

  yield todo_name
end

# Add Todo to List
post '/lists/:list_id/todos' do
  validate_list do |list_id|
    validate_todo_name do |todo|
      @list[:todos] << { name: todo, completed: false }
      session[:success] = "Todo added to list."

      redirect "/lists/#{list_id}"
    end
  end
end

# Checks if a todo_id is valid for @list. Renders the :list view if not,
# otherwise yields to the given block
def validate_todo_id
  todo_id = params[:todo_id].to_i

  unless (0...@list[:todos].size).cover? todo_id
    session[:error] = "Todo does not exist"
  end
  return erb :list if session[:error]

  yield todo_id
end

# Deletes a todo from a list
post '/lists/:list_id/todos/:todo_id/delete' do
  validate_list do |list_id|
    validate_todo_id do |todo_id|
      @list[:todos].delete_at todo_id
      session[:success] = "The todo has been removed."

      redirect "/lists/#{params[:list_id]}"
    end
  end
end

# Marks all todos complete
post '/lists/:list_id/todos/all' do
  validate_list do |list_id|
    @list[:todos].each { |todo| todo[:completed] = true }

    session[:success] = 'The list has been updated'

    redirect "lists/#{params[:list_id]}"
  end
end

# Toggles individual todo
post '/lists/:list_id/todos/:todo_id' do
  validate_list do |list_id|
    validate_todo_id do |todo_id|
      is_completed = params[:completed] == 'true'
      @list[:todos][todo_id][:completed] = is_completed
      session[:success] = 'The todo has been updated'

      redirect "/lists/#{params[:list_id]}"
    end
  end
end

# Used by view helpers to sort our todos and lists
def sorted_each(collection, sort_by_proc)
  complete, incomplete = collection.partition &sort_by_proc

  incomplete.each { |element| yield element, collection.index(element) }
  complete.each { |element| yield element, collection.index(element) }
end

helpers do
  def list_complete?(list = nil)
    list ||= @list
    !todos_count(list).zero? && todos_remaining_count(list).zero?
  end

  def list_class(list = nil)
    list ||= @list
    "complete" if list_complete? list
  end

  def todo_class(todo)
    "complete" if todo[:completed]
  end

  def todos_remaining_count(list)
    list[:todos].count { |todo| !todo[:completed] }
  end

  def todos_count(list)
    list[:todos].size
  end

  def each_sorted_list(&block)
    sort_by_proc = proc { |list| list_complete? list }

    sorted_each @lists, sort_by_proc, &block
  end

  def each_sorted_todo(todos, &block)
    sort_by_proc = proc { |todo| todo[:completed] }

    sorted_each todos, sort_by_proc, &block
  end
end
