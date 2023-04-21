module Helpers
  def require_signed_in_user
    unless session[:username]
      session[:message] = "You must be signed in to do that."
      redirect '/'
    end
  end

  def load_file_content(path)
    content = File.read path
    case File.extname path
    when '.md'
      erb render_markdown(content)
    else
      headers['Content-Type'] = 'text/plain'
      content
    end
  end

  def render_markdown(text)
    markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML
    markdown.render text
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
