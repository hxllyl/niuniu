# encoding: utf-8

module UserHelper
  
  def user_level_icons(user)
   list = case user.level
          when User::LEVELS.keys[0] then
            %w(user/typeIcon_p_dis.png user/typeIcon_s_dis.png user/typeIcon_z_dis.png)
          when User::LEVELS.keys[1] then
            %w(user/typeIcon_p.png user/typeIcon_s_dis.png user/typeIcon_z_dis.png)
          when User::LEVELS.keys[2] then
            %w(user/typeIcon_p.png user/typeIcon_s.png user/typeIcon_z_dis.png)
          else
            %w(user/typeIcon_p.png user/typeIcon_s.png user/typeIcon_z.png)
          end 
    list.unshift('user/typeIcon_p.png')      
  end
  
  def recon_icons(user)
    if user.level == User::LEVELS.keys[4]
      %w(user/typeIcon_p.png user/typeIcon_z.png)                                                         
    else
      %w(user/typeIcon_p.png user/typeIcon_z_dis.png)
    end 
  end

end