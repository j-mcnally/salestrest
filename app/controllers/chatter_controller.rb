class ChatterController < AuthenticatedController
  def show
    chatter_resp = @token.get("/services/data/v25.0/chatter/feeds/record/#{params[:id]}/feed-items")
    chatter_resp = JSON::parse(chatter_resp.body)
    
    data = chatter_resp["items"].select{|itm| itm["type"] == "TextPost"}
    
    respond_to do |format|
      format.json {
        render :json => {:chatter => data}
      }
    end
  end
end
