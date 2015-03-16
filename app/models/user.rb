# encoding: utf-8

# author: depp.yu

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable 

  # validates
  validates :name, presence: true, length: { maximum: 30 }
  validates :mobile, presence: true, format: { with:  /\A1(3|4|5|8|)\d{9}\z/ } 
  validates :role,  presence: true , inclusion: { in: %w(normal admin) }
  validates :company, presence: true, length: { maximum: 100 }
  validates :level, numericality: true, inclusion: { in: 0..3 }  

  # tables relation
  has_many :photos, as: :owner # 与图片类关联起来 处理用户图片
  has_many :posts, class_name: 'Post' # 需求和寻车
  has_many :tenders, class_name: 'Tender' # 报价
  has_many :comments, class_name: 'Comment'
  has_many :tokens, class_name: 'Token' # 用于api验证
  # constants

  ROLES = %w(normal admin)

  STATUS = {
    0  => 'unapproved',
    1  => 'approved',
    -1 => 'deleted'
  }

  LEVELS = {
    0 => '个人手机认证', # 注册时默认等级
    1 => '个人身份认证', # 上传了身份证照片
    2 => '认证资源', # 上传了营业执照        
    3 => '认证综展', # 上传了营业执照和展厅内部和门头照 个人名片
    4 => '4S' # 展厅门头照片、展厅内部照片和个人名片
  }

  # class methods

  # instance methods
  
  # devise 不用email
  def email_required?
    false
  end
  
  # 判断是不是admin
  def is_admin?
    self.role == 'admin'
  end

end
