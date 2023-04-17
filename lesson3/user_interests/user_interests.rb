require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'
require 'yaml'

before do
  @users = YAML.load_file('users.yaml')
end

get '/' do
  @title = "Users"
  erb :index
end

get '/users/:user' do
  @title = params[:user]
  @key = @title.to_sym

  @email = @users[@key][:email]
  @interests = @users[@key][:interests]

  erb :user
end

helpers do
  def count_interests
    @users.each_value.map do |user|
      user[:interests].size
    end.sum
  end
end
