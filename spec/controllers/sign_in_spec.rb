require 'rails_helper'

RSpec.describe  Users::SessionsController, type: :controller do
  include Devise::TestHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#create' do

    let(:user) { FactoryGirl.create(:personal_user, mobile: '18221849989', password: '123456') }
    it 'sign in ok' do
      sign_in user
      #subject.current_user
      expect(response.status).to eq(200)
    end
  end
end