require 'sinatra/base'
require 'yaml'
require 'bcrypt'

module Sinatra
  module CMSHelpers
    def authenticate_user?(username, password)
      users = load_user_credentials

      users.key?(username) && BCrypt::Password.new(users[username]) == password
    end

    def config_path
      File.expand_path '../../../config', __FILE__
    end

    def load_user_credentials
      credentials_path = if ENV["RACK_ENV"] == "test"
        File.expand_path '../../../test/users.yaml', __FILE__
      else
        File.expand_path '../../../config/users.yaml', __FILE__
      end
      YAML.load_file credentials_path
    end

    def load_file_content(path)
      content = File.read path
      case File.extname path
      when '.md'
        erb render_markdown(content)
      when '.txt'
        headers['Content-Type'] = 'text/plain'
        content
      end
    end

    def render_markdown(text)
      markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML
      markdown.render text
    end

    def require_signed_in_user
      return if session[:username]

      session[:message] = "You must be signed in to do that."
      redirect '/'
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
  end

  helpers CMSHelpers
end
