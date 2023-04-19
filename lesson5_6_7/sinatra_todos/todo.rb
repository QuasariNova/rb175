require "sinatra"
require "sinatra/content_for"
require "sinatra/reloader"
require "tilt/erubis"
require_relative 'lib/todo_validation'

include TodoValidation

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

def next_id list
  max = list.map { |hash| hash[:id] }.max || 0
  max + 1
end

# Create a new list
post '/lists' do
  list_name = params[:list_name].strip

  validate_list_name do |list_name|
    id = next_id session[:lists]
    session[:lists] << { name: list_name, todos: [], id: id }
    session[:success] = "The list has been created."
    redirect '/lists'
  end
end

# Renders a todo list
get '/lists/:list_id' do
  validate_list do |list_id|
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

    if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      "/lists"
    else
      session[:success] = "The list has been removed."
      redirect '/lists'
    end
  end
end

# Add Todo to List
post '/lists/:list_id/todos' do
  validate_list do |list_id|
    validate_todo_name do |todo|
      id = next_id @list[:todos]

      @list[:todos] << { id: id, name: todo, completed: false }
      session[:success] = "Todo added to list."

      redirect "/lists/#{list_id}"
    end
  end
end

# Deletes a todo from a list
post '/lists/:list_id/todos/:todo_id/delete' do
  validate_list do |list_id|
    validate_todo do |todo|
      @list[:todos].delete todo

      if env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
        status 204
      else
        session[:success] = "The todo has been removed."
        redirect "/lists/#{params[:list_id]}"
      end
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
    validate_todo do |todo|
      is_completed = params[:completed] == 'true'
      todo[:completed] = is_completed
      session[:success] = 'The todo has been updated'

      redirect "/lists/#{params[:list_id]}"
    end
  end
end

# Used by view helpers to sort our todos and lists
def sorted_each(collection, sort_by_proc)
  complete, incomplete = collection.partition &sort_by_proc

  incomplete.each { |element| yield element, element[:id] }
  complete.each { |element| yield element, element[:id] }
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
