# Adding an Index Page

Many content management systems store their content in databases, but some use files stored on the filesystem instead. This is the path we will follow with this project. Each document within the CMS will have a name that includes an extension. This extension will determine how the contents of the page are displayed in later steps.

## Requirements

1. When a user visits the home page, they should see a list of the documents in the CMS: history.txt, changes.txt and about.txt. Picture shows an unsorted list with the three documents.

### My Implementation
1. Create `about.txt`, `changes.txt`, and `history.txt` and place them somewhere in the file_cms directory. Where? I don't know, maybe a `data` folder?

2. Add `erubis` to the Gemfile and require `tilt\erubis`.

3. Detect the files and place their names into an array `@files` in the `before` helper.

4. Create a view called `views/index.erb` that houses the html for an unordered list, with each list item a different file from `@files`.

5. On the `GET '/'` path, render the view.
