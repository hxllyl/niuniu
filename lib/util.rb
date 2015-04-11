# encoding: utf-8

# author: depp.yu
require 'roo'

module Util
  
  # 导入数据工具
  module ImportFile
    
    def import_data(file_path, &block)
      raise 'FileNotFoundError' unless File.exist?file_path
      
      ext_name = File.extname(File.open(file_path))
      engine  = case ext_name
                when '.xls' then
                   Roo::Excel
                when '.xlsx'
                   Roo::Excelx
                when '.csv'
                   Roo::CSV
                end
                   
     roo_file = engine.new(file_path)    
     block.call roo_file
    end
  end
  
end


