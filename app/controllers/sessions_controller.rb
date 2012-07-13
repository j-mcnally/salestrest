class SessionsController < ApplicationController
  def destroy
    session = nil;
    redirect_to root_path
  end
end
