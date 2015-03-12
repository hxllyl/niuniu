FactoryGirl.define do
  factory :avatar, class: Photo do
    image File.open('/Users/depp/Downloads/1.jpg', 'r')
    _type 'avatar'
  end

end