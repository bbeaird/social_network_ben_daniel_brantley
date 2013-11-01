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

get '/' do
  erb :index, :locals => { :session => session }
end

post '/' do
  curr_user = User.find_by email: params[:email]
  if !curr_user || curr_user.password != params[:password]
    erb :login_failed
  else
    session[:email] = params[:email]
    erb :sign_in
  end
end

get '/friend_requests' do
  erb :friend_requests
end

post '/friend_requests' do
  FriendRequest.create user_id: User.find_by_email(session[:email]).id, request_id: params[:friend_id]
  erb :friend_requests
end

get '/accept_request' do
  redirect 'friend_requests'
end

post '/accept_request' do
  Friend.create user_id: params[:user_id], friend_id: params[:friend_id]
 # FriendRequest.all.find_by_friend_id(params[:friend_id]).delete
 # FriendRequest.where("request_id = ?", params[:friend_id]).delete
  FriendRequest.where(request_id: params[:friend_id]).destroy_all
  redirect 'friend_requests'
end

get '/sign_up' do
  erb :sign_up
end

post '/sign_up' do
  User.create(:email => params[:email], :password => params[:password], :name => params[:name])
  erb :confirm_new_user
end

get '/logout' do 
  session.clear
  redirect '/'
end

get '/search' do
  erb :search
end

post '/search' do
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
  Post.create(:title => params[:title], :body => params[:body],
              :user_id => @feed_owner.id)
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
