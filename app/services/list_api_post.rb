# encoding: utf-8

class ListApiPost

  attr_reader :cid, :sid, :bid, :style, :status, :icol, :ocol

  def initialize(opts = {})
    @cid = opts[:cid]
    @sid = opts[:sid]
    @bid = opts[:bid]
    @style = opts[:style]
    @icol = opts[:icol]
    @ocol = opts[:ocol]
    @status = opts[:status]
  end

  def call
    cond = { car_model_id: @cid, base_car_id: @style }
    res = Post.resources.where(cond)
    res = res.where(outer_color: @ocol) if @ocol
    res = res.where(inner_color: @icol) if @icol
    res = res.where(status: @status) if @status
    res
  end

  def self.call(opts = {})
    new(opts).call
  end
end