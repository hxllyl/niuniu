require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { FactoryGirl.build(:personal_user_with_avatar) }
  let(:comment) { FactoryGirl.build(:comment) }

  describe '#create' do
    it 'can be created by a user' do
      c = user.comments << comment
      user.save
      expect(user.comments.count).to eq(1)
    end

    it 'can not be create with invalid resource_type' do
      comment.resource_type = 'user'
      comment.user = user
      expect { comment.save! }.to raise_error
    end

  end
end
