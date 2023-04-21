# Adding Global Style and Behavior

When a message is displayed to a user anywhere on the site, it should be styled in a way that is easily distinguished from the rest of the page. This will help attract the user's attention to the information in the message that would otherwise be easy to miss.

While we're adding styling, we can also change the default display of the site to use a sans-serif font and have a little padding around the outside.

## Requirements
1. When a message is displayed to a user, that message should appear against a yellow background.

2. Messages should disappear if the page they appear on is reloaded

3. Text files should continue to be displayed by the browser as plain text.

4. The entire site(including markdown files, but not text files) should be displayed in a sans-serif typeface.

### My Implementation
1. Create a `:layout` view for the project that has the styling
    - Move message to the layout
    - Give message `<p>` element the `message` class.
    - Style `.message` to have yellow background
    - Set body font to a sans-serif font
    - Add <%= yield %> to layout
2. Change :edit and :index view to just be the body.
3. When a md file is loaded, call `erb` and pass its rendered content as an argument
