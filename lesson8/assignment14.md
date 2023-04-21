# Signing In and Out

Now that the content in our CMS can be modified and new documents can be created and deleted, we'd like to only allow registered users to be able to perform these tasks. To do that, though, first we'll need to have a way for users to sign in and out of the application.

## Requirements
1. When a signed-out user views the index page of the site, they should see a "Sign In" link.
2. When a user clicks the "Sign In" button, they should be taken to a new page with a sign in form. The form should contain a text input labeled "Username" and a password input labeled "Password". The form should also contain a submit button labeled "Sign In".
3. When a user enters the username "admin" and password "secret" into the sign in form and clicks the "Sign In" button, they should be signed in and redirected to the index page. A message should display that says "Welcome!".
4. When a user enters any other username and password into the sign in form and clicks the "Sign In" button, the sign in form should be redisplayed and an error message "Invalid credentials" should be shown. The username they entered into the form should appear in the username input.
5. When a signed-in user views the index page, they should see a message at the bottom of the page that says "Signed in as $USERNAME.", followed by a button labeled "Sign Out".
6. When a signed-in user clicks this "Sign Out" button, they should be signed out of the application and redirected to the index page of the site. They should see a message that says "You have been signed out.".

### My implementation
1. Create GET routes for `/users/signin` and view
    - If user is already signed in, redirect to `/`
    - renders `:signin` the sign in form that action = `/users/signin`
2. Create POST route for `/users/signin`
    - Checks if `username` is `admin` and `password` is `secret` <- Not secure
        - if so:
            1. store username into session <- Not secure
            2. then redirect to `/` with message that says `Welcome`
        - if not:
            1. message set to "Invalid credentials"
            2. Set status code `422`
            3. Render :signin
3. Create POST route for `/users/signout`
    1. Deletes username from session
    2. Set message to `You have been signed out.`
    3. redirects to `/`
5. Edit `:index` view
    - If `session[:username]` exists
        - Add form to sign out at the bottom
            - action is `/users/signout` and method is `post`
            - Text says `Signed in as #username`
            - Submit next to it that says `Sign Out`
    - Otherwise
        - Have sign in link that goes to `/users/signin`
6. Create tests (might need to add session data?)
    - Test sign in form view
        1. Route to `/users/signin`
        2. Check that body contains correct form
    - Test invalid sign in
        1. POST `/users/signin` with bad credentials
        2. Status code is `422`
        3. Check for message `Invalid credentials`
    - Test correct sign in
        1. Post `/users/signin` with good credentials
        3. Route to Location
        4. Check for `Welcome` message
        6. Check that `Signed in as admin.` is in body.
    - Test for sign out
        1. Post `/users/signin` with good credentials
        2. Route to Location
        3. Check for `Welcome` message
        4. POST `/users/signout`
        5. Check that `You have been signed out.` is in body
        6. Check that `Sign In` is in body
