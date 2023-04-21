# Storing User Accounts in an External File
## Requirements
1. An administrator should be able to modify the list of users who may sign into the application by editing a configuration file using their text editor.

### My Implementation
1. Create `/config/users.yaml`
    - Store user as key, password as value
2. Create `authenticate_user?` that takes a username and password as parameters
    - Checks if yaml has username as key
    - Checks if that key has the same value as password
    - If not, return false
    - Else return true
3. On the `POST /users/signin` route change it to run `authenticate_user?` to check if the user logs in
