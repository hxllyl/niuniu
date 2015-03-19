# encoding: utf-8

# author: depp.yu
require 'util'
require 'csv'

namespace :util do
  include ::Util::ImportFile

  desc '系统初始化数据'
  task init: :environment do
    Rake::Task["util:import"].invoke
    Rake::Task["util:import_areas"].invoke
  end

  desc "数据导入"
  task import: :environment do
    file_path = "#{Rails.root}/doc/base_car_data.xlsx"

    import_data(file_path) { |roo|
      (roo.first_row.succ..roo.last_row).each do |i|
        columns = (roo.first_column..roo.last_column).collect do |j|
          roo.cell(i,j)
        end

       st = Standard.find_or_initialize_by( name: columns[0] )
       br = Brand.find_or_initialize_by( name: columns[1] )
       bc = BaseCar.find_or_initialize_by( model: columns[2], style: columns[3],
                                 NO: columns[4].to_i.to_s, base_price: columns[5].scan(/\d+\.\d+/).first.to_f*10000
                                )

       st.save

       br.standard = st
       br.regions = columns[8].split('、')
       br.save

       bc.brand, bc.standard = br, st
       bc.outer_color = columns[6].split(' ')
       bc.inner_color = columns[7].split(' ')
       bc.save

     end
    }
  end

  desc "import chinese province and city data"
  task import_areas: :environment do
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
  task import_brands: :environment do
    domain  = 'iniuniu.com.cn'
    tmp_dir = Rails.root + 'public' + 'uploads'

    csv_file = '/Users/depp/brands.csv'
    csv_text = File.read(csv_file)

    csv = CSV.parse(csv_text, headers: true)
    csv.each_with_index do |row, i|
      ha = row.to_hash
      brand = Brand.find_or_initialize_by(name: ha["name"])

      system("wget -O #{tmp_dir}/#{i}.jpg #{domain}#{ha['path']}")
      brand.photo = Photo.new image: File.open("#{tmp_dir}/#{i}.jpg")
      brand.save!
    end
  end

end
