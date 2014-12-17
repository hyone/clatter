- User
  - screen_name
  - email
  - name
  - description 160文字 (optional)
  - url (optional)
  - icon_url (optional)
  - private

- Post
  - text
  - user_id
  - favorited
  - created_at
  - reply_to (optional)

- Relationship
  - follower_id     # follow した人
  - followed_id     # follow された人

- Retweet
  - id
  - post_id
  - original_id
  - created_at

- DirectMessage
  - user_id
  - to_id
  - text
  - created_at
