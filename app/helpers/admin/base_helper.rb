module Admin::BaseHelper

  def nav_class_name(item_name)
    return 'active' if params[:controller] == "admin/#{item_name}"
    return ''
  end

  def get_resource_name(resource_type, resource_id)
    ele = resource_type.classify.constantize.find_by_id(resource_id)

    if [User, Staff].include?(ele.class)
      '用户'
    elsif ele.class == Post
      Post::TYPES[ele._type]
    else
      ''
    end
  end

  def get_resource_url(resource_type, resource_id)
    ele = resource_type.classify.constantize.find_by_id(resource_id)

    if [User, Staff].include?(ele.class)
      user_list_posts_path(user_id: ele.id, _type: 0)
    elsif ele.class == Post
      post_path(ele, _type: ele._type)
    else
      ''
    end
  end

end
