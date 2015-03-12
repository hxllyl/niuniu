FactoryGirl.define do
  factory :avatar, class: Photo do
    image File.open('../test_files/1.jpg', 'r')
    _type 'avatar'
  end

end