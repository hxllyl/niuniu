# encoding: utf-8

class Log::Post < ActiveRecord::Base
  # tag: 此日志中的存的是method_names: [:view, :tender, :post_completed, :tender_completed, :update_resources]
  #      view是某用户浏览的资源日志
  #      当某用户将他的寻车与某个报价成交时，会生成一个post_completed的日志，而且相对应的报价的日志也会由tender更新成tender_completed
  #      update_resources一键更新，这个日志主要用于限制用户频繁更新自己的资源，用户是否可以更新自己的资源将会以instance_method的方式呈现在User里面
  # resources: view
  # needs: tender, post_completed, tender_completed

  belongs_to :user, class_name: 'User'
  # belongs_to :post, class_name: 'Post', foreign_key: :post_id

  scope :views, -> { where(method_name: 'view').order(updated_at: :desc) }

  scope :completeds, -> { where(method_name: /completed/) }

  scope :update_resources, -> { where(method_name: 'update_all').order(created_at: :desc) }

  scope :last_months, ->(num) { where("created_at > ? and created_at < ?", Time.now.ago(num.months), Time.now) }

  scope :already_read, -> { where(:read => true) }
  scope :not_read, -> { where(:read => false ) }

  scope :tender_to_posts, ->(post_ids) { where(:method_name => :tender, :post_id => Array(post_ids) ) } # 提醒寻车方
  scope :hunt_completed,  ->(u_id) { where(:method_name => :tender_completed, user_id: u_id ) } # 提醒报价方

end
