# Editing Document Content

Now it’s time to allow users to modify the content stored within our CMS.
## Requirements

1. When a user views the index page, they should see an “Edit” link next to each document name.

2. When a user clicks an edit link, they should be taken to an edit page for the appropriate document.

3. When a user views the edit page for a document, that document's content should appear within a textarea.

4. When a user edits the document's content and clicks a “Save Changes” button, they are redirected to the index page and are shown a message: `$FILENAME has been updated..`

### My Implementation
1. Update the `:index` view to include linkes to edit the filenames with the path `/:filename/edit`

2. Create an `:edit` view. That has a form with a text area and a submit button
    - Text area needs to have the content of the file, so use `<%= @content %>` in it.
    - Form will have method `post`
    - action should be `/:filename`

3. Create a `post '/:filename'` path
    1. Takes the data from the form and saves it to the file indicated by `:filename`.
    2. Adds a message to the session saying `:filename has been updated.`
    3. Redirects to `/`

4. Create a tests for editing files
    - Test for :edit view
        1. route GET route for some file
        2. Status code = 200
        3. Content-Type right
        4. Body contains form

    - Test for changing file
        1. route POST route for some file and send `content:`
        2. Status code = 302 (303 in prod)
        3. route get to `Location`
        4. check if message displayed
        5. route GET to file
        6. Status code = 200
        6. Check that contents changed
