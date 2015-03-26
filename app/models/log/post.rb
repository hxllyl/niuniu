# encoding: utf-8
class Log::Post < ActiveRecord::Base
  # tag: 此日志中的存的是method_names: [:view, :tender, :post_completed, :render_completed]
  #      当某用户提交完成他的寻车时，相对应某个报价的日志也会有tender更新成tender_completed
end
