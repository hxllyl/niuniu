FactoryGirl.define do
  factory :comment do
    resource_type 'Comment'
    resource_id 1
    content "hello"
  end
end
