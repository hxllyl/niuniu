require 'digest'

FactoryGirl.define do
  sequence(:mobile, 1000) {|n| "131#{n}#{n}"}
  sequence(:name){|n| "test#{n}" }

  
  trait :common do
    name
    mobile
    salt "--test--"
    encrpt_password Digest::SHA1.hexdigest("--test--")
  end
  
  factory :personal_user do
    common
    level 1
  end
  
  factory :personal_user_with_avatar, class: User do
    common
    level 2
    after(:create) do |owner|
      create(:avatar, owner: owner)
    end
  end
end