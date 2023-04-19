# Viewing Text Files
This is a good time to add some content to the files in the data directory of the project. Feel free to use any text you'd like; you can also use the Ruby release dates list below.

## Requirements

1. When a user visits the index page, they are presented with a list of links, one for each document in the CMS.

2. When a user clicks on a document link in the index, they should be taken to a page that displays the content of the file whose name was clicked.

3. When a user visits the path /history.txt, they will be presented with the content of the document history.txt.

4. The browser should render a text file as a plain text file.

### My Implementation

1. Add text to `about.txt`, `changes.txt`, and `history.txt`.

2. Add a `GET /:filename` route.
    1. This route will take the `:filename`, load the file, and return the file as a string.
    2. Make sure to set the `Content-Type` header to plain text.

3. Modify `views/index.rb` to link each file to their respective route.
