# encoding: utf-8

class Api::BaseController < ApplicationController

  layout :false
  skip_before_filter :verify_authenticity_token


end
