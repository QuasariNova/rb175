ENV["RACK_ENV"] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open File.join(data_path, name), 'w' do |file|
      file.write content
    end
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

  def test_files
    create_document 'changes.txt', 'I am change'

    get '/changes.txt'

    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, 'I am change'
  end

  def test_markdown
    create_document 'about.md', '# Ruby is...'
    get '/about.md'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<h1>Ruby is...</h1>'
  end

  def test_no_file
    get '/no-file'
    assert_equal 302, last_response.status

    path = last_response['Location']
    get path
    assert_includes last_response.body, 'no-file does not exist.'

    get path
    refute_includes last_response.body, 'no-file does not exist.'
  end

  def test_edit_view
    create_document 'changes.txt'
    get '/changes.txt/edit'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<textarea'
  end

  def test_modify
    post '/changes.txt', content: "File has changed"

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, 'changes.txt has been updated.'

    get '/changes.txt'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'File has changed'
  end

  def test_new_view
    get '/new'

    assert_equal 200, last_response.status
    assert_includes last_response.body, '<form action="/create" method="post">'
  end

  def test_new_no_filename
    post '/create', filename: '   '

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'A name is required.'
  end

  def test_new_new_filename
    post '/create', filename: 'new'

    assert_equal 200, last_response.status
    assert_includes last_response.body, "'new' is not a valid name."
  end

  def test_new_create_filename
    post '/create', filename: 'create'

    assert_equal 200, last_response.status
    assert_includes last_response.body, "'create' is not a valid name."
  end

  def test_new_file
    post '/create', filename: 'file.txt'

    assert_equal 302, last_response.status

    get last_response['Location']
    assert_includes last_response.body, 'file.txt was created.'

    get '/'
    assert_includes last_response.body, 'file.txt'
  end
end
