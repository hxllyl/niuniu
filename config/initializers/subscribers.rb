ActiveSupport::Notifications.subscribe('user.update_level') do |name, start, finish, id, payload|
  Log::UserUpdateLevel.create(payload)
end

ActiveSupport::Notifications.subscribe('user.has_read_tender') do |name, start, finish, id, payload|
  Log::Post.not_read.where(:post_id => Array(payload[:post_id]), method_name: 'tender').update_all(read: true)
end

ActiveSupport::Notifications.subscribe('user.has_read_hunt') do |name, start, finish, id, payload|
  Log::Post.not_read.where(:user_id => payload[:user_id],
                           post_id: Array(payload[:post_id]), method_name: :tender_completed).update_all(read: true)
end


ActiveSupport::Notifications.subscribe('user.has_read_sys_message') do |name, start, finish, id, payload|
  UserMessage.unread.where(user_id: payload[:user_id] ).update_all(status: 1)
end

ActiveSupport::Notifications.subscribe('contact_phone.send_invite_message') do |name, start, finish, id, payload|
  Rails.logger.debug('name = '+ name)
  Rails.logger.debug('start = '+ start.strftime('%Y/%m/%d %H:%M'))
  #Rails.logger.debug('end = ' + end.to_s)
  Rails.logger.debug('id = '+ id.to_s)
  Rails.logger.debug('payload = '+ payload.to_s)
  Log::ContactPhone.create(payload)
end