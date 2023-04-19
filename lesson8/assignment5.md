## Requirements
1. Write tests for the routes that the application already supports.

### My Implementation
1. Add `minitest` and `rack-test` to `Gemfile`

2. Set up test file in `test/cms_test.rb`.

3. Create a test for the index `test_index`
    1. run `get '/'`
    2. Assert that the status code is `200`
    3. Assert that the `Content-Type` is `text/html;charset-utf-8`
    4. Assert that the body is correct

4. Create a test for the `/:filename` path `test_files`
    - For each path `/about.txt`, `/changes.txt`, and `/history.txt`
        1. Assert that the status code is `200`
        2. Assert that the `Content-Type` is `text/plain`
        3. Assert that the body is the same as the contents as the file

5. Run the tests.
