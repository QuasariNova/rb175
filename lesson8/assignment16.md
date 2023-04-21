# Restricting Actions to Only Signed-in Users
## Requirements
1. When a signed-out user attempts to perform the following actions, they should be redirected back to the index and shown a message that says "You must be signed in to do that.":

    - Visit the edit page for a document
    - Submit changes to a document
    - Visit the new document page
    - Submit the new document form
    - Delete a document

### My Implementation
1. Create helper `require_signed_in_user`
    - Check if `session[:username] exists
        - If not, set message to `You must be signed in to do that` and redirect to `/`
2. Invoke `require_signed_in_user` on these routes:
    - `GET '/:filename/edit`
    - `POST '/:filename'`
    - `GET '/new'`
    - `POST '/create'`
    - `POST '/:filename/delete'`
3. Change tests for these to login.
    - `test_edit_view`
    - `test_modify`
    - `test_new_view`
    - `test_new_no_filename`
    - `test_new_new_filename`
    - `test_new_create_filename`
    - `test_new_file`
    - `test_delete`
4. Create new tests to test for error message when logged out.
