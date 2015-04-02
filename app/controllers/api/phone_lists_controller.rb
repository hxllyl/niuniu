# encoding: utf-8

class Api::PhoneListsController < Api::BaseController
  
  def index
    raise '请上传通讯录用户' if params[:contacts].blank? or params[:contacts].empty?
    
    params[:contacts].each do |contact|
      
    end
    
  end
end