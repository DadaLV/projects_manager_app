require 'rails_helper'

RSpec.describe 'SessionsController', type: :request do
  describe 'POST api/v1/auth/sign_in' do
    let(:user) { create :user }
    it 'signs in a user successfully' do
      post '/api/v1/auth/sign_in', params: user.slice(:email, :password)
      expect(response).to have_http_status(200)
      expect(response.headers['access-token']).to be_present
      expect(response.headers['client']).to be_present
      expect(response.headers['uid']).to eq(user.email)
      expect(response.headers['expiry']).to be_present
    end

    it 'returns unauthorized for incorrect password' do
      post '/api/v1/auth/sign_in', params: { email: 'test4@test.com', password: 'wrong_password' }
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE api/v1/auth/sign_out' do
    let(:user) { create :user }
    it 'signs out a user successfully' do
      post '/api/v1/auth/sign_in', params: user.slice(:email, :password)
      expect(response).to have_http_status(200)

      access_token = response.headers['access-token']
      client = response.headers['client']
      uid = response.headers['uid']

      delete '/api/v1/auth/sign_out', headers: {
        'access-token': access_token,
        'client': client,
        'uid': uid
      }
      expect(response).to have_http_status(200)

      get '/api/v1/auth/validate_token', headers: {
        'access-token': access_token,
        'client': client,
        'uid': uid
      }

      expect(response).to have_http_status(401)
    end
  end
end
