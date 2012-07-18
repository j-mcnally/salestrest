

class SobjectsController < AuthenticatedController
  
  
  
  def index
    respond_to do |format|
      format.json {
        resp = @token.get("/services/data/v23.0/sobjects/");
        resp = JSON::parse(resp.body)
        sobjects = resp["sobjects"].collect{|s| {name: s["name"], label: s["label"], prefix: s["keyPrefix"]} }
        sobjects << {name: "___Pinned", label: "Pinned", prefix: "000"}
        render :json => sobjects.to_json
      }
      format.html
    end

  end

  def pin
    
    respond_to do |format|
      format.json {
       
        resp = @token.post("/services/data/v23.0/chatter/users/me/following", :params => { :subjectId => params[:id] });
        status = resp.status
        resp = JSON::parse(resp.body)
        
        if status > 200 && status < 400
          render :json => resp
          return 
        else
          render :json => {code: "error"}
          return
        end
        
      }
    end 
  end
  def unpin
    
    respond_to do |format|
      format.json {
       
        resp = @token.delete("/services/data/v23.0//chatter/subscriptions/#{params[:id]}");
        status = resp.status
        
        if status > 200 && status < 400
          render :json => {code: "ok"}
          return 
        else
          render :json => {code: "error"}
          return
        end
        
      }
    end 
  end
  
  
  def show
    @object = params[:id]
    respond_to do |format|
      format.json {
        if params[:id] == '___Pinned'
          resp = @token.get("/services/data/v23.0/chatter/users/me/following")
          resp = JSON::parse(resp.body)
          
          
          
          items = resp["following"]
          items = items.select{|i| i["type"] != "User"}
          
          
          
          resp = items.collect{|i| {:subject => i["subject"], :type => i["subject"]["type"]} }
          
          subscriptions = {}
          
          items.each do |item|
            subscriptions["#{item["subject"]["id"]}"] = item["id"];
          end
          
          
          
          
          
          data = {};
         
          
          resp.each do |r|
            
            data["#{r[:type]}"] = [] unless data["#{r[:type]}"].present?
            data["#{r[:type]}"] << "'#{r[:subject]["id"]}'"
          end
          
         
          
          objs = [];
          
          data.each do |obj, ids|
            if objs.empty?
              objs = getData(obj, "WHERE id IN (#{ids.join(",")})")
            else
              res = getData(obj, "WHERE id IN (#{ids.join(",")})")
              objs["totalSize"] += res["totalSize"]
              objs["records"] += res["records"]
              
            end
          end
          objs.flatten(1);
          
          
          
          objs["records"].each do |r|
            puts "#{r["Id"]} => #{subscriptions["#{r["Id"]}"]}"
            r["subscriptionId"] = subscriptions["#{r["Id"]}"] if subscriptions["#{r["Id"]}"].present?
          end
          
          puts objs["records"].inspect;
          
          render :json => {:data => objs}
          return
        else
        
          resp = getData(params[:id])
          
          puts resp.inspect
          
          render :json => {:data => resp}
        end
          
      }
      format.html
    end
  end
  
  def getData(obj, clause = nil)
  
    resp = @token.get("/services/data/v23.0/sobjects/#{obj}/describe")
    resp = JSON::parse(resp.body)
  
  
    fields = [];
    resp["fields"].each do |f|
      key = f["name"]
      unless key.include?("__c") || key.include?("Id") || key.include?("Is") || key.include?("Date") || key.include?("stamp")
        fields << key
      end
    end
    fields << "Id"
    fields << "CreatedDate"

    #Bootstrap request with generic query
    if clause.present?
      query = CGI::escape("Select #{fields.join(', ')} FROM #{obj} #{clause}")
    else
      query = CGI::escape("Select #{fields.join(', ')} FROM #{obj}")
    end
    
    puts query;
    
    resp = @token.get("/services/data/v23.0/query/?q=#{query}");
    resp = JSON::parse(resp.body)
  
  
    resp["records"].each do |record|
      fresp = []
      i = 0
    
    
    
      record.each_pair do |key, val|
        fresp << {:key => key.underscore.humanize.capitalize, :val => val} unless val.nil? || val == '' || key == 'attributes' || key == 'CreatedDate'
        i += 1
        break if i > 5
      
      end
      record["fields__api"] = fresp
    end
 
    return resp
  end
  
end
