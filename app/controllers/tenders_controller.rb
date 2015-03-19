# encoding: utf-8
# 只有寻车有
class TendersController < ApplicationController

  def show
    @tender = Tender.find_by_id(params[:id])
  end

end
