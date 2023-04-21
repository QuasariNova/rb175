ENV["RACK_ENV"] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def admin_session
    {"rack.session" => { username: "admin" }}
  end

  def app
    Sinatra::Application
  end

  def create_document(name, content = "")
    File.open File.join(data_path, name), 'w' do |file|
      file.write content
    end
  end

  def session
    last_request.env["rack.session"]
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def test_index_view
    create_document 'about.md'
    create_document 'changes.txt'

    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, "about.md"
    assert_includes last_response.body, "changes.txt"
  end

  def test_document_view
    create_document 'changes.txt', 'I am change'

    get '/changes.txt'

    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, 'I am change'
  end

  def test_markdown_view
    create_document 'about.md', '# Ruby is...'
    get '/about.md'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<h1>Ruby is...</h1>'
  end

  def test_no_file
    get '/no-file'
    assert_equal 302, last_response.status
    assert_equal 'no-file does not exist.', session[:message]
  end

  def test_edit_view
    create_document 'changes.txt'
    get '/changes.txt/edit', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<textarea'
  end

  def test_edit_view_signed_out
    create_document 'changes.txt'
    get '/changes.txt/edit'

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_modify
    post '/changes.txt', { content: "File has changed" }, admin_session

    assert_equal 302, last_response.status
    assert_equal 'changes.txt has been updated.', session[:message]

    get '/changes.txt'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'File has changed'
  end

  def test_modify_signed_out
    post '/changes.txt', { content: "File has changed" }

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_new_view
    get '/new', {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<form action="/create" method="post">'
  end

  def test_new_view_signed_out
    get '/new'
    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_new_no_filename
    post '/create', { filename: '   ' }, admin_session

    assert_equal 422, last_response.status
    assert_includes last_response.body, 'A name is required.'
  end

  def test_new_new_filename
    post '/create', { filename: 'new' }, admin_session

    assert_equal 422, last_response.status
    assert_includes last_response.body, "'new' is not a valid name."
  end

  def test_new_create_filename
    post '/create', { filename: 'create' }, admin_session

    assert_equal 422, last_response.status
    assert_includes last_response.body, "'create' is not a valid name."
  end

  def test_new_file
    post '/create', { filename: 'file.txt' }, admin_session

    get last_response['Location']
    assert_includes last_response.body, 'file.txt was created.'

    get '/'
    assert_includes last_response.body, 'file.txt'
  end

  def test_new_file_signed_out
    post '/create', { filename: 'file.txt' }

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_delete
    create_document 'test.txt'

    post '/test.txt/delete', {}, admin_session

    assert_equal 'test.txt has been deleted.', session[:message]

    get last_response['Location']
    get '/'
    refute_includes last_response.body, 'test.txt'
  end

  def test_delete_signed_out
    create_document 'test.txt'

    post 'test.txt/delete'

    assert_equal 302, last_response.status
    assert_equal 'You must be signed in to do that.', session[:message]
  end

  def test_signin_view
    get '/users/signin'

    assert_includes last_response.body,
                    '<form action="/users/signin" method="post">'
  end

  def test_signin_invalid
    post '/users/signin', username: 'not', password: 'valid'

    assert_equal 422, last_response.status
    assert_includes last_response.body, 'Invalid credentials.'
  end

  def test_signin_valid
    post '/users/signin', username: 'admin', password: 'secret'

    assert_equal 'Welcome!', session[:message]
    assert_equal 'admin', session[:username]

    get last_response['Location']
    assert_includes last_response.body, 'Signed in as admin.'
  end

  def test_signout
    get '/', {}, {"rack.session" => {username: "admin"}}
    assert_includes last_response.body, 'Signed in as admin.'

    post '/users/signout'
    assert_equal 'You have been signed out.', session[:message]

    get last_response['Location']
    assert_nil session[:username]
    assert_includes last_response.body, 'Sign In'
  end
end
