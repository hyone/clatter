- User
  - screen_name:string
  - email:string
  - name:string
  - description:string 160文字 (optional)
  - url:string (optional)
  - profile_image:string (optional)
  - private:bool

- Message
  - text:string
  - user_id:references (User)

- Follow
  - follower_id:references (User)     # follow した人
  - followed_id:references (User)     # follow された人

- Reply
  - message_id:references (Message)
  - to_message_id:references (Message) (optional)
  - to_user_id:references (User) (required)

- Favorite
  - user_id:references
  - message_id:references (Message)

- Retweet
  - id
  - message_id
  - original_id
  - created_at

- DirectMessage
  - user_id
  - to_id
  - text
  - created_at
