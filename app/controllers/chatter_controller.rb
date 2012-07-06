class ChatterController < AuthenticatedController
  def show
    chatter_resp = @token.get("/services/data/v25.0/chatter/feeds/record/#{params[:id]}/feed-items")
    chatter_resp = JSON::parse(chatter_resp.body)
    
    data = chatter_resp["items"].select{|itm| itm["type"] == "TextPost"}
    
    data.map{|i| i["created_at"] = Time.parse(i["createdDate"]).strftime("%b, %d %l:%M %P") }
    
    respond_to do |format|
      format.json {
        render :json => {:chatter => data}
      }
    end
  end
  def create

    new_comment = @token.post("/services/data/v25.0/chatter/feeds/record/#{params[:id]}/feed-items", :params => {:text => params["text"] })
    new_comment = JSON::parse(new_comment.body)
     respond_to do |format|
      format.json {
        render :json => {:comment => new_comment}
      }
    end
  end
end
