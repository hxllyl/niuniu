# encoding: utf-8

class Staff < User
  
  ROLES = %(staff admin superadmin)
  
  validates :job_number, presence: true
  
  scope :customer_services, -> { where(role: 'staff') }
  
end