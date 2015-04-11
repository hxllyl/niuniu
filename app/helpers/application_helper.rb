# encoding: utf-8

module ApplicationHelper

  def human_time(time)
    if time < Date.today
      time.strftime("%m/%d")
    else
      time.strftime("%H:%M")
    end
  end

  def active?(controller_name, current_controller_name)
    'active' if controller_name == current_controller_name
  end

  def post_active?(controller_name, current_controller_name, type, current_type)
    'active' if controller_name == current_controller_name && type == current_type
  end

end
