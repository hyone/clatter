99.times { |n| 
  user = FactoryGirl.create(:user)
  if n < 5
    99.times { |m|
      if m % 5 == 0
        FactoryGirl.create(:post_replied, user: user)
      else
        FactoryGirl.create(:post, user: user)
      end
    }
  end
}
