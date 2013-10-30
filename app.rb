require 'sinatra'
require 'active_record'
require_relative './app/models/user'

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
  elsif curr_user.password != params[:password]
    erb :login_failed
  else
    session[:email] = params[:email]
    erb :sign_in
  end
end

get '/sign_up' do
  erb :sign_up
end

post '/sign_up' do
  User.create(:email => params[:email], :password => params[:password])
  erb :confirm_new_user
end

get '/logout' do 
  session.clear
  redirect '/'
end
