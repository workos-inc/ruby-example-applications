# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'workos'
require 'json'

# Pull API key from ENV variable
WorkOS.key = ENV['WORKOS_API_KEY']

# Input your connection ID from your WorkOS dashboard
# Configure your Redirect URIs on the dashboard
# configuration page.
CONNECTION_ID = ENV['WORKOS_CONNECTION_ID']
CLIENT_ID = ENV['WORKOS_CLIENT_ID']
REDIRECT_URI = 'http://localhost:4567/callback'


use(
  Rack::Session::Cookie,
  key: 'rack.session',
  domain: 'localhost',
  path: '/',
  expire_after: 2_592_000,
  secret: SecureRandom.hex(16)
)

get '/' do
  erb :login, :layout => :layout
end


post '/set_org' do
  organization_id = params[:org]

  session[:organization_id] = organization_id
  
  organization = WorkOS::Organizations.get_organization(
  id: organization_id
  )

  org_name = organization.name
  session[:organization_name] = org_name
  redirect '/'
end  

get '/auth' do
  puts CONNECTION_ID
  authorization_url = WorkOS::SSO.authorization_url(
    client_id: CLIENT_ID,
    connection: CONNECTION_ID,
    redirect_uri: REDIRECT_URI,
  )
  puts authorization_url
  redirect authorization_url
end



# Logout a user
get '/logout' do
  session[:user] = nil

  redirect '/'
end
