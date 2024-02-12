require 'rails_helper'

RSpec.describe "Api::V1::Tasks", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }

  before do
    post '/api/v1/auth/sign_in', params: { email: user.email, password: user.password }
    @auth_headers = user.create_new_auth_token
  end

  describe "GET /api/v1/projects/:project_id/tasks" do
    let!(:tasks) { create_list(:task, 5, project: project) }

    before do
      get "/api/v1/projects/#{project.id}/tasks", headers: @auth_headers, as: :json
    end

    it "returns all tasks for a project" do
      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(5)
      expect(json_response[0]['name']).to eq(tasks.first.name)
    end
  end

  describe 'POST /api/v1/projects/:project_id/tasks' do
    let(:valid_attributes) { { name: 'New Task', description: 'New task description', status: 'new' } }
  
    it 'creates a new task for the specified project' do
      expect {
        post "/api/v1/projects/#{project.id}/tasks", params: { task: valid_attributes }, headers: @auth_headers
      }.to change(Task, :count).by(1)
  
      expect(response).to have_http_status(:created)
      expect(json_response['name']).to eq('New Task')
      expect(json_response['description']).to eq('New task description')
      expect(json_response['status']).to eq('new')
    end
  end

  describe 'PUT /api/v1/projects/:project_id/tasks/:id' do
    let!(:task) { create(:task, project: project, name: 'Original Task', description: 'Original description', status: 'new') }
    let(:updated_attributes) { { name: 'Updated Task', description: 'Updated description', status: 'completed' } }
  
    it 'updates the requested task' do
      put "/api/v1/projects/#{project.id}/tasks/#{task.id}", params: { task: updated_attributes }, headers: @auth_headers
  
      task.reload
      expect(response).to have_http_status(:ok)
      expect(task.name).to eq('Updated Task')
      expect(task.description).to eq('Updated description')
      expect(task.status).to eq('completed')
    end
  end

  describe 'DELETE /api/v1/projects/:project_id/tasks/:id' do
    let!(:task) { create(:task, project: project) }
  
    it 'deletes the task' do
      expect {
        delete "/api/v1/projects/#{project.id}/tasks/#{task.id}", headers: @auth_headers
      }.to change(Task, :count).by(-1)
  
      expect(response).to have_http_status(:no_content)
    end

    context 'when the task does not belong to the current user' do
      let(:other_user) { create(:user) }
      let(:other_user_project) { create(:project, user: other_user) }
      let!(:other_user_task) { create(:task, project: other_user_project) }

      it 'does not allow the task to be deleted' do
        delete "/api/v1/projects/#{other_user_project.id}/tasks/#{other_user_task.id}", headers: @auth_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
