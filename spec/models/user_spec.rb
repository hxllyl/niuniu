require 'rails_helper'

RSpec.describe User, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  
  describe '#photos' do
    let(:user){ FactoryGirl.create(:personal_user_with_avatar) }
    
    it 'user photos count equal 1' do
      expect(user.photos.count).to eq 1
    end

    it 'user photos first _type equal avatar' do
      expect(user.photos.first._type).to eq 'avatar'
    end

    it 'user photos image extname equal jpg' do
      expect(user.photos.first.image.path).to match(/1\.jpg/)
    end
  end
end
