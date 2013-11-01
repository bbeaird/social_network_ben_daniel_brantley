class User < ActiveRecord::Base
  has_many :posts
  has_many :friends
  has_many :friend_requests
end
