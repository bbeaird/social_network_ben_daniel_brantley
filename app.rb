require 'sinatra'
require 'active_record'
require 'sinatra/flash'
require 'bcrypt'
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

# Index displays login if no session.  Else the user is brought to their control panel.
get '/' do
  if session[:email] != nil
    erb :user_cp
  else
  erb :index, :locals => { :session => session }
  end
end

# Validates user on login.
post '/' do
  curr_user = User.find_by email: params[:email]
  if !curr_user || BCrypt::Password.new(curr_user.hex_digest) != params[:password]
    erb :login_failed
  else
    session[:email] = params[:email]
    erb :user_cp
  end
end

# Show friend requests. (DEPRECATED)
get '/friend_requests' do
  erb :friend_requests
end

# Handles friend requests when a user sends, accepts, or rejects a requeset.
post '/friend_requests' do
  # If user is sending a request...
  if params[:action] == "send" 
    # Deletes existing duplicate friend requests
    if FriendRequest.find_by_user_id_and_request_id(User.find_by_email(session[:email]).id, params[:friend_id]) != nil
      FriendRequest.find_by_user_id_and_request_id(User.find_by_email(session[:email]).id, params[:friend_id]).destroy
    end
    # Creates friend request.
    FriendRequest.create user_id: User.find_by_email(session[:email]).id, request_id: params[:friend_id]
    erb :friend_requests
  elsif params[:action] == "accept"
      # Create friend from friend request.
      Friend.create user_id: params[:user_id], friend_id: params[:friend_id]
      # Delete the friend request and any duplicate requests.
      FriendRequest.where(request_id: params[:friend_id]).destroy_all
      redirect '/'
    elsif params[:action] == "reject"
      FriendRequest.find_by_request_id(params[:friend_id]).destroy
      redirect '/'
  end
end

# Display signup page.
get '/sign_up' do
  erb :sign_up
end

post '/sign_up' do
  crypt_digest = BCrypt::Password.create(params[:password])
  new_user = User.new(:email => params[:email], :hex_digest => crypt_digest.to_s, :name => params[:name])
  if new_user.valid? 
    new_user.save
    erb :confirm_new_user
  else
    erb :sign_up
  end
end

# Logs out any sessions.
get '/logout' do 
  session.clear
  redirect '/'
end


get '/search' do
  erb :search
end

get '/search/query' do
  found_user = User.find_by email: params[:email]
  if found_user
    redirect '/' + found_user.id.to_s
  else
    flash[:notice] = "Sorry, we don't have any users with that email address."
    redirect '/search'
  end
end

get '/:page_id' do
  @session_user_id = session[:id]
  @feed_owner = User.find_by id: params[:page_id]
  if !session[:email]
    erb :must_log_in
  else
    unless @feed_owner
      "No user exists with that ID!"
    else
      erb :user_feed
    end
  end
end

post '/:page_id' do
  @feed_owner = User.find_by id: params[:page_id]
  Post.create(:title => params[:title], :body => params[:body], :user_id => @feed_owner.id)
  erb :user_feed
end

get '/:page_id/new' do
  @feed_owner = User.find_by id: params[:page_id]
  if @feed_owner.email == session[:email]
    erb :new_post
  else
    "Sorry, only the owner of this feed can post here."
  end
end


get '/user_cp' do
  @current_user = User.find_by email: session[:email]
  erb :user_cp
end