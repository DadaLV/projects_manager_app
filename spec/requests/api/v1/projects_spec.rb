require 'rails_helper'

RSpec.describe "Api::V1::Projects", type: :request do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }

  before do
    post '/api/v1/auth/sign_in', params: { email: user.email, password: user.password }
    @auth_headers = user.create_new_auth_token
  end

  describe "GET /api/v1/projects" do
    let!(:projects) { create_list(:project, 3, user: user) }
    let!(:other_projects) { create_list(:project, 3, user: user2) }
    

    before do
      get api_v1_projects_path, headers: @auth_headers, as: :json
    end

    it "returns all projects for the current user" do

      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(3)
      expect(json_response[0]['name']).to eq(projects.first.name)
    end
  end

  describe 'POST /api/v1/projects' do
    let(:valid_attributes) { { name: 'New Project', description: 'New project description' } }

    before do
      get api_v1_projects_path, headers: @auth_headers, as: :json
    end
  
    it 'creates a new project for the current user' do
      expect {
        post api_v1_projects_path, params: { project: valid_attributes }, headers: @auth_headers
      }.to change(user.projects, :count).by(1)
  
      expect(response).to have_http_status(:created)
      expect(json_response['name']).to eq('New Project')
      expect(json_response['description']).to eq('New project description')
    end
  end

  describe 'PUT /api/v1/projects/:id' do
    let!(:project) { create(:project, user: user, name: 'Original Name', description: 'Original description') }
    let(:other_user_project) { create(:project, user: user2) }
    let(:updated_attributes) { { name: 'Updated Name', description: 'Updated description' } }
  
    it 'updates the requested project' do
      put api_v1_project_path(project), params: { project: updated_attributes }, headers: @auth_headers
  
      project.reload
      expect(response).to have_http_status(:ok)
      expect(project.name).to eq('Updated Name')
      expect(project.description).to eq('Updated description')
    end

    it 'does not allow updating a project not owned by the current user' do
      put api_v1_project_path(other_user_project), params: { project: updated_attributes }, headers: @auth_headers
      
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    let!(:project) { create(:project, user: user) }
    let(:other_user_project) { create(:project, user: user2) }
  
    it 'deletes the project' do
      expect {
        delete api_v1_project_path(project), headers: @auth_headers
      }.to change(user.projects, :count).by(-1)
  
      expect(response).to have_http_status(:no_content)
    end

    it 'does not allow deleting a project not owned by the current user' do
      delete api_v1_project_path(other_user_project), headers: @auth_headers
      
      expect(response).to have_http_status(:not_found)
    end
  end
end
