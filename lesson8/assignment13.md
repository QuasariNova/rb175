# Deleting Documents
## Requirements

1. When a user views the index page, they should see a "delete" button next to each document.
2. When a user clicks a "delete" button, the application should delete the appropriate document and display a message: "$FILENAME has been deleted".

### My Implementation
1. Add button to each document
    - Add form to each document in index that `action` is `/:filename/delete` and `method` is `post`
    - Make submit button next to document with value of `delete`
2. Create `post` path `/:filename/delete`
    - Verify file exists
    - delete file
    - set message to `:filename has been deleted`
    - redirect to `/`
3. Create test
    - Test that file will be deleted
        1. Create file `test.txt`
        2. `post '/test.txt/delete`
        3. status is `302`
        4. get Location
        5. contains `test.txt has been deleted`
        6. get '/'
        7. Doesn't contain `test.txt`
