# encoding: utf-8

FactoryGirl.define do
  factory :avatar, class: Photo do
    image File.open(Rails.root.to_s + '/spec/test_files/1.jpg', 'r')
    _type 'avatar'
  end

end
