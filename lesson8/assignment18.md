# Storing Hashed Passwords
## Requirements
1. User passwords must be hashed using bcrypt before being stored so that raw passwords are not being stored anywhere.

### My Implementation
1. Add `gem 'bcrypt'` to `Gemfile`
2. In `lib/helpers.rb` `require 'bcrypt'`
3. In our `authenticate_user?` method, run the stored password through `BCrypt::Password.new` before using `==` to compare it to the given one.
4. Update `users.yaml` in both `test/` and `config/` to have hashed passwords.

---
### Questions
1. True or false: Running the same password through `bcrypt` multiple times will result in the same hashed value every time.

False. `bcrypt` will use a random salt each time, creating different hashes.
