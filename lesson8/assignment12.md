# Creating New Documents
## Requirements
1. When a user views the index page, they should see a link that says "New Document".
2. When a user clicks the "New Document" link, they should be taken to a page with a text input labeled "Add a new document:" and a submit button labeled "Create".
3. When a user enters a document name and clicks "Create", they should be redirected to the index page. The name they entered in the form should now appear in the file list. They should see a message that says "$FILENAME was created.", where $FILENAME is the name of the document just created.
4. If a user attempts to create a new document without a name, the form should be re-displayed and a message should say "A name is required."

### My implementation
1. Add a link to create a new file on `:index` with path '/new'
2. Create a new path `/new` prior to `/:filename` so that it triggers before it
    - Render `:new`
3. Create new view `:new` that is a form to create a new file
    - send a post to `/` with filename = form
4. Create a new post path `/`
    1. Check that filename is valid (not empty, not `new`)
    2. If not, render `:new` with error message
    3. If so, redirect to `/`
5. Create tests
    - Test `/new` renders form
    - Test `post '/'` works correctly with good filename and message that it was created
    - Test `post '/'` displays error with bad filename

---
## Questions
1. What will happen if a user creates a document without a file extension? How could this be handled?

With how launch school did this, the file would be created, but when you tried to view content, it would not display. There are two ways to handle this:

    - Don't allow files to be created without an extension
    - Render any file you don't know the type of as a text file

I chose to render them as a plaintext file.
