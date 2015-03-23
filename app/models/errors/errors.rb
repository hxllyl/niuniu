module Errors
  class InvaildVaildCodeError < StandardError; end
  class UserNotFoundError < StandardError; end
  class ValidCodeNotFoundError < StandardError; end
  class ArgumentsError < StandardError; end
end  