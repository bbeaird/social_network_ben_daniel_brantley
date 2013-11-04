class User < ActiveRecord::Base
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: "not a valid email"}
  validates :name, presence: true
  validates :hex_digest, presence: true
  has_many :posts
  has_many :friends
  has_many :friend_requests
end
