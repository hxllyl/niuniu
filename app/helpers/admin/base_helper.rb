module Admin::BaseHelper

  def nav_class_name(item_name)
    return 'active' if params[:controller] == "admin/#{item_name}"
    return ''
  end
  
end
