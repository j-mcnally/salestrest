class SessionsController < ApplicationController
  def destroy
    session = nil
    redirect root_path
  end
end
