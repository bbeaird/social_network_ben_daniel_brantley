require 'sinatra'
require 'active_record'
require 'sinatra/flash'
require_relative './app/models/user'
require_relative './app/models/post'
require_relative './app/models/friend'
require_relative './app/models/friend_request'


ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                        database: 'social_network')

set :session_secret, ENV["SESSION_KEY"] || 'too secret'

enable :sessions

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

# # p Friend.all.first

# @feed_owner = User.all.find(6)

# Friend.all.each do |friend|
#   if friend.user_id == @feed_owner.id
#     p User.find(friend.friend_id).name
#   end
# end


# p User.find(Friend.all.first.friend_id).email

FriendRequest.all.each do |request|
  # if User.all.find(request.user_id).id == @session_user_id 
  # p request.name
  # end
  # p User.all.
  if User.all.find(request.user_id).id == @session_user_id
    p request.name
  end
end