require "cgi"

class AuthenticatedController < ApplicationController
  before_filter :oauth_client
  before_filter :grab_sobjects
  
  rescue_from OAuth2::Error, :with => :rescue_oauth
    
  def rescue_oauth ex
    
    puts ex.inspect
    
    errorCode = ex.response.parsed.first["errorCode"]
    
    if errorCode == "INVALID_SESSION_ID"
      
      @client.site = "https://login.salesforce.com"
      
      session[:access_token] = nil
      
      create_client
      
      
    end
  
  end
  
  def grab_sobjects
    types = @token.get('/services/data/v23.0/sobjects/')
    @types = JSON::parse(types.body)["sobjects"].reject{|t| !t["feedEnabled"] }
  end
end
