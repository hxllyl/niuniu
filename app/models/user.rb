# encoding: utf-8

# author: depp.yu

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, stretches: 20 

  # validates
  validates :name, presence: true, length: { maximum: 30 }
  validates :mobile, presence: true, format: { with:  /\A1(3|4|5|8|)\d{9}\z/ } 
  validates :role, inclusion: { in: %w(normal admin) }
  validates :company, presence: true, length: { maximum: 100 }
  validates :level, numericality: true, inclusion: { in: 0..3 }  

  # tables relation
  has_many :photos, as: :owner # 与图片类关联起来 处理用户图片

  # constants

  ROLES = %w(normal admin)

  STATUS = {
    0  => 'unapproved',
    1  => 'approved',
    -1 => 'deleted'
  }

  LEVELS = {
    0 => '个人',
    1 => '认证资源',
    2 => '认证综展',
    3 => '4S'
  }

  # class methods

  # instance methods

end
