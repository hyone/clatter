follow ||= false

json.array! users, partial: 'users/user', follow: follow, as: :user
