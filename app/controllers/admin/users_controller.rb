# app/controllers/admin/users_controller.rb
class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:show]

  def index
    @pagy, @users = pagy(User.where(role: :user).order(created_at: :asc))
  end

  def show
    if @user.date_of_birth.present?
      today = Date.today
      @age = today.year - @user.date_of_birth.year
      @age -= 1 if Date.today < @user.date_of_birth + @age.years
    end

    # Phân trang borrow requests
    @pagy, @borrow_requests = pagy(@user.borrow_requests.order(created_at: :desc))
  end

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

  def toggle_status
    if @user.active?
      @user.inactive!
    else
      @user.active!
    end
    redirect_to admin_user_path(@user), notice: "User status updated successfully."
  end
end
