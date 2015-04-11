require 'rails_helper'

RSpec.describe Photo, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  
  # author: depp.yu
    
  describe '#save' do
    let(:avatar) { FactoryGirl.create(:avatar)  }
    it "'s end with 1.jpg" do
      expect(avatar.image.path).to match(/vatar1\.jpg/)
    end
  end  
  
end