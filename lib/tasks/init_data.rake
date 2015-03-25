# encoding: utf-8
# author: depp.yu
require 'pty'

namespace :database do

  desc "init database and run migrations"
  task init: :environment do
    cmds = ['rake db:drop', 'rake db:create', 'rake db:migrate']

    cmds.each do |_cmd|
      begin
        PTY.spawn( _cmd ) do |r, w, pid|
          begin
            r.each {|line| print line; }
          rescue Errno::EIO
          end
        end
      rescue Exception => e
        puts 'some wrong happen' + e.message
        next
      end
    end

  end

  desc "准备的基础数据"
  task base_infos: :environment do
    Rake::Task["database:users"].invoke
    Rake::Task["database:posts"].invoke
    Rake::Task["database:tenders"].invoke
  end

  desc "生成用户数据"
  task users: :environment do
    # Users
    ha = {
      name:     'test',
      mobile:   '15802162343',
      role:     User::ROLES[0],
      level:    User::LEVELS.keys[0],
      status:   User::STATUS.keys[1],
      password: '123456',
      company: 'test',
      area: Area.last
    }
    user = User.create(ha) unless User.find_by_mobile(ha[:mobile])

    ha_1 = {
      name:     'admin',
      mobile:   '15802162344',
      role:     User::ROLES[1],
      level:    User::LEVELS.keys[0],
      status:   User::STATUS.keys[1],
      password: '123456',
      company: 'test',
      area: Area.last
    }

    admin = User.create(ha_1) unless User.find_by_mobile(ha_1[:mobile])
  end

  desc "生成 post 数据"
  task posts: :environment do
    user_ids = User.all.map(&:id)
    pics     = Array(0..4)
    pics_dir = Rails.root + 'public' + 'cars'
    100.times do
      standard = Standard.all.sample
      brand    = standard.brands.sample
      car_model = brand.car_models.sample
      base_car = car_model.base_cars.sample
      post     = Post.new(
                 _type:             [0, 1].sample,
                 standard_id:       standard.id,
                 brand_id:          brand.id,
                 user_id:           user_ids.sample,
                 car_model_id:      car_model.id,
                 outer_color:       base_car.outer_color.sample,
                 inner_color:       base_car.inner_color.sample,
                 car_license_areas: Area.first.name,
                 car_in_areas:      brand.regions.sample(2),
                 discount_way:      1,
                 discount_content:  0.9,
                 resource_type:     [0, 1].sample
               )
      if post._type == 0
        %w(front side obverse inner).each do |ele|
          post.post_photos.new(_type: ele, image: File.open("#{pics_dir}/#{pics.sample}.jpg"))
        end
      end
      post.base_car = base_car
      post.save
    end
  end

  desc "生成 tenders 数据"
  task tenders: :environment do

    discount_hash = {
      1 => %w(0.99 0.94 0.9 0.87 0.8),
      2 => %w(1 2 3 4),
      3 => %w(1 2 3 4),
      4 => %w(20 55 30.4),
      5 => %w(电议)
    }

    Post.needs.each do |need|
      if need != 3
        user = User.where("id <> #{need.user_id}").first

        discount_way            = discount_hash.keys.sample
        discount_content        = discount_hash[discount_way].sample
        tender                  = Tender.new
        tender.post             = need
        tender.discount_way     = discount_way
        tender.discount_content = discount_content
        tender.user             = user
        tender.save
      end
    end

    Post.needs.sample(10).each do |need|
      need.complete(need.tenders.first.id)
    end
  end

end
