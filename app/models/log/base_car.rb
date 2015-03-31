# encoding: utf-8
# 此日志模型是专为客户自定义车型颜色而加的,另外，车型，车款，自定义时都是直接创建，状态设为未审核，由后台管理员去审核管理
class Log::BaseCar < ActiveRecord::Base

  belongs_to :user, class_name: 'User'
  belongs_to :base_car, class_name: 'BaseCar', foreign_key: :base_car_id
end
