require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do

  include Devise::TestHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#create' do
    let(:user) { FactoryGirl.create(:personal_user, mobile: '18221849989', password: '123456') }
    it 'will response ok' do
      request.path = '/'
      post :create, session: {mobile: '18221849989', password: '123456', company: 'Lankr',
                              password_confirmation: '123456', name: 'leslie'}
      expect(response.status).to eq(200)
      # expect(response).to redirect_to(root_path)
    end
  end

  describe '#sign in' do

  end
end