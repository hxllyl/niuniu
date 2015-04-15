# encoding: utf-8

module DeviseFailed
  
  class CustomFailure < Devise::FailureApp
    
    def redirect_url
       root_path
    end
    
    def respond 
      if request.format == :json or request.content_type == 'application/json'
        json_failure
      else
        flash[:error] = '找不到用户！'
        super
      end
    end
    
    
    def json_failure
      self.status = 401
      self.content_type = 'application/json'
      self.response_body = { status: 400, notice: 'failed', data: {}}.to_json
    end
    
  end
  
end