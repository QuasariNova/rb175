In this assignment, we'll set up the project and add a placeholder route to make sure everything is ready for the rest of the project.

## Requirements
1. When a user visits the path "/", the application should display the text "Getting started."

### My Implementation:
1. Create Folder for project. This is a file based content management system, so we'll call it file_cms.

2. Create Gemfile that includes gems for `sinatra`, `sinatra-contrib`, and `webrick` and use bundler to create the Gemfile.lock.

3. Create our main rb file. We'll call it cms.rb. It needs to require:
    1. `sinatra`
    3. `sinatra/reloader` if we want it to automatically reload every change

4. Create our GET / route and have it return `"Getting started."`

5. `ruby cms.rb` to test it is working.
