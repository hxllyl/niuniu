# encoding: utf-8

class Api::BaseController < ApplicationController

  layout :false
  
  protect_from_forgery with: :null_session
  skip_before_filter :verify_authenticity_token


end
