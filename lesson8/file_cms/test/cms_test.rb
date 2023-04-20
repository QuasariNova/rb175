ENV["RACK_ENV"] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get '/'
    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, "about.md"
    assert_includes last_response.body, "changes.txt"
    assert_includes last_response.body, "history.txt"
  end

  def test_files
    root = File.expand_path "..", __FILE__
    ['/changes.txt', '/history.txt'].each do |path|
      get path
      assert_equal 200, last_response.status
      assert_equal 'text/plain', last_response['Content-Type']

      contents = File.read "#{root}/../data#{path}"
      assert_equal contents, last_response.body
    end
  end

  def test_markdown
    get '/about.md'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end

  def test_no_file
    get '/no-file'
    assert_equal 302, last_response.status

    path = last_response['Location']
    get path
    assert_includes last_response.body, "no-file does not exist."

    get path
    refute_includes last_response.body, "no-file does not exist."
  end
end
