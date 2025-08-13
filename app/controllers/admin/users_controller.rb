# app/controllers/admin/users_controller.rb
class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:show]

  def index
    @pagy, @users = pagy(User.where(role: :user).order(created_at: :asc))
  end

  def show; end

  private

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role)
  end

  def require_admin
    redirect_to root_path, alert: "Access denied" unless current_user&.admin?
  end
end
