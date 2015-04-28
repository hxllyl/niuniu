# encoding: utf-8

class Admin::FeedbacksController < Admin::BaseController
  
  def index
    @feedbacks = Feedback.order('updated_at desc').page(params[:page]).per(30)  
  end
  
end