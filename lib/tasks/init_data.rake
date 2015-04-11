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
    Rake::Task["database:posts_views"].invoke
    Rake::Task["database:follow_ships"].invoke
  end

  desc "生成用户数据"
  task users: :environment do
    # Users
    mobiles = %w(15802162343 18101880251)
    companies = %w(流浪客ty晶晶 上海嘉玮汽车 中国大自然汽车有限责任公司 上海防冻汽车交易公司 上海嘉玮汽车 上海嘉玮汽车 旭日汽车 上海郎客 杭州鼎臻汽车销售有限公司 天津港宏顺通汽车销售有限公司 牛牛汽车0002 牛牛汽车 牛牛汽车 牛牛汽车 天津市晟信源汽车销售有限公司 天津路驰汽车贸易有限公司 天津路通世纪国际贸易有限公司 杭州鼎欧汽车销售有限公司 北京博辰骏达汽车销售有现公司 北京中汽顺合汽车)
    names = %w(进口商 改名晶晶 吴嘉明 555 向顺 吴嘉明 周芳芳 洪旭 郭里 池姑娘 吴可嘉 韩健 石雨璐 张继兰 王西 杨光远 马清亮 于景欣 杭州鼎欧名车.沈忠 孙树毓 郭智东)
    mobiles.each do |mobile|
      comp = companies.sample
      ha = {
        name:     names.sample,
        mobile:   mobile,
        role:     User::ROLES[[0, 1].sample],
        level:    User::LEVELS.keys[0],
        status:   User::STATUS.keys[1],
        password: '123456',
        company: comp,
        area_id: Area.all.sample.id,
        contact: {company_address: comp, position_header: '客服经理', wx: '5656565', qq: '12345678'}
      }
      User.create(ha) unless User.find_by_mobile(mobile)
    end
  end

  desc "生成 post 数据"
  task posts: :environment do
    user_ids = User.all.map(&:id)
    pics     = Array(0..4)
    pics_dir = Rails.root + 'public' + 'cars'
    100.times do
      base_car = BaseCar.all.sample
      post     = Post.new(
                 _type:             [0, 1].sample,
                 standard_id:       base_car.standard_id,
                 brand_id:          base_car.brand_id,
                 user_id:           user_ids.sample,
                 car_model_id:      base_car.car_model_id,
                 outer_color:       (base_car.outer_color.sample rescue '白色'),
                 inner_color:       (base_car.inner_color.sample rescue '黑色'),
                 car_license_area:  Area.first.name,
                 car_in_area:       base_car.brand.regions.sample,
                 discount_way:      1,
                 discount_content:  0.9
               )
      if post._type == 0
        post.resource_type = [0, 1].sample
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

    Post.needs.sample(100).each do |need|
      if need != 3
        User.where("id <> #{need.user_id}").sample(rand(5)).each do |user|

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
    end

    Post.needs.sample(10).each do |need|
      need.complete(need.tenders.first.id) if need.tenders.first
    end
  end

  desc "生成post浏览记录"
  task posts_views: :environment do
    Post.resources.sample(50).each do |post|
      u_ids = User.where("id <> #{post.user_id}").map(&:id)
      u_ids.sample(rand(20)).each do |user_id|
        Log::Post.create(user_id: user_id, method_name: 'view', post_id: post.id)
      end
    end
  end

  desc "生成follow_ships"
  task follow_ships: :environment do
    u_ids = User.all.map(&:id)
    100.times do
      ids = u_ids.sample(2)
      fs = FollowShip.find_or_initialize_by(follower_id: ids[0], following_id: ids[1])
      fs.save
    end
  end

end
