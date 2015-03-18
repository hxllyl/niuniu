# encoding: utf-8

# author: depp.yu

module Errors
  class UserNotFoundError < StandardError
    def initialize(msg)
      super msg
    end
  end
  class InValidValidCodeError < StandardError;end
end