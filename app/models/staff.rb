# encoding: utf-8

class Staff < User
  
  ROLES = %(staff admin superadmin)
  
  validates :job_number, presence: true
  
  scope :customer_services, -> { where(role: 'staff') }
  
  has_many :customers, -> {where(role: 'staff')}, class_name: 'User', foreign_key: :customer_service_id
  has_many :feedbacks, class_name: 'Message', foreign_key: 'receiver_id'
end