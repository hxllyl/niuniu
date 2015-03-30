ActiveSupport::Notifications.subscribe('user.update_level') do |name, start, finish, id, payload|
  Log::UserUpdateLevel.create(payload)
end