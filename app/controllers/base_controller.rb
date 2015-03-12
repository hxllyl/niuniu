# encoding: utf-8

#author: depp.yu

class BaseController < ApplicationController
  
  before_action :authenticate_user!
end