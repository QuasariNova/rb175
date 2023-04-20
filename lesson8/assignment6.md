# Handling Requests for Nonexistent Documents

We aren't focusing too much on testing techniques or philosophy in this course, but it is still a good idea to start thinking about what kind of tests you'd need to write to verify the behavior of an application as it changes.

Try to write a test for this assignment by describing exactly what the user does (shown below under Requirements). The solution for the test is shown separately below if you'd like to see it without seeing the rest of the implementation.

## Requirements
1. When a user attempts to view a document that does not exist, they should be redirected to the index page and shown the message: $DOCUMENT does not exist.
2. When the user reloads the index page after seeing an error message, the message should go away.

### My Implementation
1. Enable sessions in the application
    - In `configure` block, `enable :sessions`
    - Set `:session_secret`
2. On the `/:filename` path, detect if the file exists.
    - if it does, treat the path like normal
    - If not, store `"$DOCUMENT does not exist"` in the session and redirect to the `/` route
3. On the `:index` template, check if the error message exists
    - If so, display the message and delete it
    - else do nothing
4. Create a test for nonexistant documents.
    1. Try a route that will give the error `/no-file`
    2. Check that the response sends a `302` status code stating it will redirect.
    3. Get the `Location` from the header
    4. Route to the location and check that the message appears
    5. Route again to the location and check that the message doesn't appear
