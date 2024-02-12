class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :authenticate_api_v1_user!
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    projects = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      current_api_v1_user.projects.includes(:tasks).to_a
    end
    render json: projects, include: { tasks: { only: [:id, :name, :description, :status] } }
  end

  def show
    render json: @project, include: { tasks: { only: [:id, :name, :description, :status] } }
  end

  def create
    @project = current_api_v1_user.projects.build(project_params)

    if @project.save
      clear_tasks_cache
      render json: @project, status: :created, location: api_v1_project_url(@project)
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      clear_tasks_cache
      render json: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    clear_tasks_cache
    head :no_content
  end

  private

  def set_project
    @project = current_api_v1_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def cache_key
    "user_#{current_api_v1_user.id}_projects"
  end

  def clear_tasks_cache
    Rails.cache.delete(cache_key)
  end
end
