# encoding: utf-8

# author: depp.yu
require 'util'
require 'csv'

namespace :util do
  include ::Util::ImportFile

  desc '系统初始化数据'
  task init: :environment do
    Rake::Task["util:base_cars"].invoke
    Rake::Task["util:areas"].invoke
    Rake::Task["util:brands"].invoke
  end

  desc "数据导入"
  task base_cars: :environment do
    file_path = "#{Rails.root}/doc/base_car_data.xlsx"

    import_data(file_path) { |roo|
      puts 'start import base_cars'

      (roo.first_row.succ..roo.last_row).each do |i|
        columns = (roo.first_column..roo.last_column).collect do |j|
          roo.cell(i,j)
        end


      begin
       st = Standard.find_or_initialize_by(name: columns[0].chomp)
       br = Brand.find_or_initialize_by(name: columns[1].chomp)
       cm = CarModel.find_or_initialize_by(
              name: (columns[2] || ' ').to_s.chomp,
              display_name: (columns[2] || ' ').to_s.chomp
            )
       bc = BaseCar.find_or_initialize_by(
              style: columns[3].chomp,
              display_name: columns[3].chomp,
              NO: columns[4].to_i.to_s,
              base_price: columns[5].to_f
            )

       st.save

       br.standards << st unless br.standards.include?(st)
       br.regions = columns[8].split(' ') if columns[8]
       br.status = 1
       br.save

       cm.standard = st
       cm.brand = br
       cm.save

       bc.standard, bc.brand, bc.car_model = st, br, cm
       bc.outer_color = columns[6].split(' ') if columns[6]
       bc.inner_color = columns[7].split(' ') if columns[7]
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

  desc "导入汽车品牌（临时任务）"
  task brands: :environment do
    domain  = 'http://iniuniu.com.cn'
    tmp_dir = Rails.root + 'public' + 'uploads'

    csv_file = "#{Rails.root}/doc/brands.csv"
    csv_text = File.read(csv_file)

    csv = CSV.parse(csv_text, headers: true)
    csv.each_with_index do |row, i|
      ha = row.to_hash
      brand = Brand.find_or_initialize_by(name: ha["name"])

      system("wget -O #{tmp_dir}/#{i}.jpg #{domain}#{ha['path']}")

      brand.car_photo = CarPhoto.new(_type: 'brand', image: File.open("#{tmp_dir}/#{i}.jpg"))
      begin
        brand.save!
      rescue ActiveRecord::RecordNotSaved => e
        brand.errors.full_messages
      end
    end
  end

end
