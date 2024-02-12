require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe 'POST /api/v1/auth' do
    context 'with valid parameters' do
      let(:valid_params) { { email: 'test@example.com', password: 'password123', password_confirmation: 'password123' } }

      it 'registers a new user' do
        post '/api/v1/auth', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(response.headers['uid']).not_to be_nil
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { email: '', password: '' } }

      it 'returns unprocessable entity status' do
        post '/api/v1/auth', params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post '/api/v1/auth', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']['full_messages']).to include("Password can't be blank", "Email can't be blank")
      end
    end

    context 'with an email that has already been taken' do
      let(:existing_user) { create :user }
      let(:duplicate_email_params) { { email: existing_user.email, password: 'password456', password_confirmation: 'password456' } }

      before do
        existing_user
      end

      it 'returns unprocessable entity status' do
        post '/api/v1/auth', params: duplicate_email_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an email already taken error message' do
        post '/api/v1/auth', params: duplicate_email_params
        expect(json_response['errors']['full_messages']).to include('Email has already been taken')
      end
    end
  end
end
