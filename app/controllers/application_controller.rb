class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  
  
  
  def create_client
    @client = OAuth2::Client.new(SFDC_CONFIG['consumer_key'], SFDC_CONFIG['consumer_secret'], :site => 'https://login.salesforce.com', :authorize_url => '/services/oauth2/authorize', :token_url => '/services/oauth2/token')
    if session[:access_token].present? && session[:token_options].present?
      @token = OAuth2::AccessToken.new(@client, session[:access_token], session[:token_options])
      @token.client.site = @token.params['instance_url']
      return @token
    elsif params[:code]
      token = @client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
      session[:access_token] = token.token
      session[:token_options] = {refresh_token: token.refresh_token}.merge(token.params).merge(token.options)
      redirect_to root_path
      return
    else
      redirect_to @client.auth_code.authorize_url(:redirect_uri => redirect_uri)
      return
    end
  end
  
  def current_user
    oauth_client.present?
  end
  
  def redirect_uri
    "https://#{request.host}#{request.port == '80' ? '' : ":#{request.port}"}/sessions/oauth/callback"
  end
  
  def token
    @token ||= oauth_client
  end
  
  def oauth_client
    @oauth_client ||= create_client
  end
  
end
