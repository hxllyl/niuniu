# encoding: utf-8
class Admin::ComplaintsController < Admin::BaseController
  before_filter :require_ad

  def index
    @complaints = Complaint.includes(:resource, :user, :operator).valid.order(updated_at: :desc).page(params[:page]||1).per(30)
  end

  def update
    @complaint = Complaint.find_by_id(params[:id])
    @complaint.update_attributes(status: params[:status].to_i, operator_id: current_user.id)

    redirect_to :back
  end

end
