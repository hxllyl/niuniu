require 'rails_helper'

RSpec.describe Photo, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  
  # author: depp.yu
  # before :each do
  #   @user  = User.first
  #   @photo = Photo.new
  # end
  
  let(:file) { File.open('/Users/depp/Downloads/1.jpg', 'r')}
  let(:type) {'avatar'}
  
  it 'initial photo and relative it to @user avatar' do
    # @photo.owner = @user
    # @photo._type = type
    # @photo.image = file
    # @photo.save
    #
    # @photo.reload.owner.should eq @user
    # @photo.reload._type.should eq 'avatar'
    # @photo.reload.image.should_not eq nil
    FactoryGirl
    
  end
  
end
