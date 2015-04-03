ActiveSupport::Notifications.subscribe('user.update_level') do |name, start, finish, id, payload|
  Log::UserUpdateLevel.create(payload)
end

ActiveSupport::Notifications.subscribe('user.has_read_tender') do |name, start, finish, id, payload|
  Log::Post.not_read.where(:post_id => payload[:post_id], method_name: 'tender').update_all(read: true)
end

ActiveSupport::Notifications.subscribe('user.has_read_hunt') do |name, start, finish, id, payload|
  Log::Post.not_read.where(:user_id => payload[:user_id],
                           post_id: payload[:post_id], method_name: :tender_completed).update_all(read: true)
end