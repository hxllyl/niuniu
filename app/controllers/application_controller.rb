require 'forwardable'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  extend Forwardable
  
  def_delegator ActiveSupport::Notifications, :instrument

end
