

class SobjectsController < AuthenticatedController
  def index
    respond_to do |format|
      format.json {
        resp = @token.get("/services/data/v23.0/sobjects/");
        resp = JSON::parse(resp.body)
        sobjects = resp["sobjects"].collect{|s| {name: s["name"], label: s["label"], prefix: s["keyPrefix"]} }
        render :json => sobjects.to_json
      }
      format.html
    end

  end
  def show
    @object = params[:id]
    respond_to do |format|
      format.json {
        
        resp = @token.get("/services/data/v23.0/sobjects/#{params[:id]}/describe")
        resp = JSON::parse(resp.body)
        fields = [];
        resp["fields"].each do |f|
          key = f["name"]
          unless key.include?("__c") || key.include?("Id") || key.include?("Is") || key.include?("Date") || key.include?("stamp")
            fields << key
          end
        end
        fields << "Id"
    
        #Bootstrap request with generic query
        query = CGI::escape("Select #{fields.join(', ')} FROM #{params[:id]}")
        resp = @token.get("/services/data/v23.0/query/?q=#{query}");
        resp = JSON::parse(resp.body)
        
        
        resp["records"].each do |record|
          fresp = []
          i = 0
          record.each_pair do |key, val|
            fresp << {:key => key.underscore.humanize.capitalize, :val => val} unless val.nil? || val == '' || key == 'attributes'
            i += 1
            break if i > 5
            
          end
          record["fields__api"] = fresp
        end
        
        render :json => {:data => resp}
      }
      format.html
    end
  end
end
