# encoding: utf-8

class ComplaintsController < BaseController

  def create
    obj = complaint_params[:resource_type].classify.constantize.find_by_id(complaint_params[:resource_id])
    fail ' complaint object is not valid' if obj.blank?

    complaint = current_user.complaints.new(complaint_params)
    complaint.save!

    respond_to do |format|
      format.html {
        flash[:notice] = t('success')
        redirect_to :back
      }
      format.js {}
    end
  rescue => e
    respond_to do |format|
      format.html {
        flash[:error] = complaint.errors.full_message.join('\n')
        redirect_to :back
      }
      format.js {}
    end
  end

  private
  
  def complaint_params
    params[:complaint].permit(:resource_type, :resource_id, :content, :user_id)
  end
end