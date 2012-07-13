require "cgi"

class AuthenticatedController < ApplicationController
  before_filter :oauth_client
  before_filter :grab_sobjects, :if => Proc.new{|c| c.request.format.html?}
  
  before_filter :me, :if => Proc.new{|c| c.request.format.html?}
  
  rescue_from OAuth2::Error, :with => :rescue_oauth
    
  def rescue_oauth ex
    
    errorCode = ex.response.parsed.first["errorCode"]
    
    if errorCode == "INVALID_SESSION_ID"
      
      @client.site = "https://login.salesforce.com"
      
      session[:access_token] = nil
      
      create_client
      
      
    end
  
  end
  def me
    me = @token.get('/services/data/v23.0/chatter/users/me')
    @me = JSON::parse(me.body)
  end
  
  def grab_sobjects
    types = @token.get('/services/data/v23.0/sobjects/')
    
    @types = JSON::parse(types.body)["sobjects"].reject{|t| !t["feedEnabled"] }
    @types.unshift({"name" => "___Pinned", "label" => "Pinned"});
  end
end
