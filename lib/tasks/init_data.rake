# encoding: utf-8
# author: depp.yu
require 'pty'

namespace :init_data do
  
  desc "init database and run migrations"
  task create_database: :environment do
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
  
end
