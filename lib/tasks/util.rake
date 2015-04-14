# encoding: utf-8
# author: depp.yu
require 'util'
require 'csv'

namespace :util do
  include ::Util::ImportFile

  desc '系统初始化数据'
  task init: :environment do
    # Rake::Task["util:brands"].invoke
    Rake::Task["util:areas"].invoke
    Rake::Task["util:base_cars"].invoke
  end

  desc "数据导入"
  task base_cars: :environment do
    file_path = "#{Rails.root}/doc/base_car_data.xlsx"

    brand_icons_dir = Rails.root + 'public' + 'brand_icons'

    import_data(file_path) { |roo|
      puts 'start import base_cars'

      (roo.first_row.succ..roo.last_row).each do |i|
        columns = (roo.first_column..roo.last_column).collect do |j|
          roo.cell(i,j)
        end

      begin
       raise '规格 品牌 车型 车款 不能为空' if [columns[0],columns[1],columns[2],columns[4]].include?(nil)

       st = Standard.find_or_initialize_by(name: columns[0].chomp.strip)
       st.save if st.new_record?

       br = Brand.find_or_initialize_by(name: columns[1].chomp.strip)
       if br.new_record?
         br.status = 1
         br.regions = columns[10].split(' ') if columns[10]
         br.car_photo = CarPhoto.new(_type: 'brand', image: File.open("#{brand_icons_dir}/#{br.name}.png"))
         br.save
       end

       st.brands << br unless st.brands.include?(br)
       st.save

       br.standards << st unless br.standards.include?(st)
       br.save

       cm = CarModel.find_or_initialize_by(
              standard_id: st.id,
              brand_id: br.id,
              name: columns[2].to_s.split('.').first.strip.chomp,
              display_name: columns[3].to_s.split('.').first.strip.chomp
            )
       cm.save

       bc = BaseCar.find_or_initialize_by(
              standard_id: st.id,
              brand_id: br.id,
              car_model_id: cm.id,
              style: columns[4].strip.chomp,
              display_name: columns[5].to_s.split('.').first.strip.chomp,
              NO: columns[6].to_i.to_s,
              base_price: columns[7].to_f
            )
       bc.outer_color = columns[8].split(' ') if columns[8]
       bc.inner_color = columns[9].split(' ') if columns[9]
       bc.save
     rescue => ex
       puts 'some wrong happend: ' + ex.message
       next
     end
   end
    }
    puts "end import base_cars"
  end

  desc "import chinese province and city data"
  task areas: :environment do
    file_path = "#{Rails.root}/doc/areas.xls"

    import_data(file_path) { |roo|
      (roo.first_row.succ..roo.last_row).each do |i|
        columns = (roo.first_column..roo.last_column).collect do |j|
          roo.cell(i,j)
        end

        parent = Area.find_or_initialize_by( name: columns[1], level: Area::LEVELS[:province] )
        child  = Area.find_or_initialize_by( name: columns[2], level: Area::LEVELS[:city] )

        parent.save

        child.parent = parent
        child.save
      end
    }
  end

  # desc "导入汽车品牌（临时任务）"
  # task brands: :environment do
  #   domain  = 'http://iniuniu.com.cn'
  #   tmp_dir = Rails.root + 'public' + 'uploads'

  #   csv_file = "#{Rails.root}/doc/brands.csv"
  #   csv_text = File.read(csv_file)

  #   csv = CSV.parse(csv_text, headers: true)
  #   csv.each_with_index do |row, i|
  #     ha = row.to_hash
  #     brand = Brand.find_or_initialize_by(name: ha["name"], status: 0)

  #     system("wget -O #{tmp_dir}/#{i}.jpg #{domain}#{ha['path']}")

  #     brand.car_photo = CarPhoto.new(_type: 'brand', image: File.open("#{tmp_dir}/#{i}.jpg"))
  #     begin
  #       brand.save!
  #     rescue ActiveRecord::RecordNotSaved => e
  #       brand.errors.full_messages
  #     end
  #   end
  # end

end
