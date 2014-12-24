- User
  - screen_name:string
  - email:string
  - name:string
  - description:string 160文字 (optional)
  - url:string (optional)
  - profile_image:string (optional)
  - private:bool

- Post
  - text
  - user_id
  - reply_to (optional)

text:string user_id:references created_at:datetime reply_to:references

- Favorite
  - user:references
  - post:references

- Relationship
  - follower:references     # follow した人
  - followed:references     # follow された人

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
