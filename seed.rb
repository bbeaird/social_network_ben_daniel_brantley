require 'sinatra'
require 'active_record'
require 'sinatra/flash'
require 'faker'
require_relative './app/models/user'
require_relative './app/models/post'
require_relative './app/models/friend'

ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                        database: 'social_network')

set :session_secret, ENV["SESSION_KEY"] || 'too secret'

enable :sessions

10.times do
  User.create(:email => Faker::Internet.email, :password => Faker::Lorem.word, :name => Faker::Name.name)
end

5.times do 
  new_friend = Friend.create(:friend_id => (rand(9)+1), :user_id => (rand(9)+1))
  User.update((rand(9)+1), :friends_id => new_friend.id)
end