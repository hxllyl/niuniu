class ComplaintsController < BaseController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    obj = complaint_params[:resource_type].classify.constantize.find_by_id(complaint_params[:resource_id])
    fail ' complaint object is not valid' if obj.blank?

    complaint = User.last.complaints.new(complaint_params)
    complaint.save!

    render text: 'ok'
  rescue => e
    render text: e.message
  end

  private
  
  def complaint_params
    params[:complaint].permit(:resource_type, :resource_id, :content)
  end
end