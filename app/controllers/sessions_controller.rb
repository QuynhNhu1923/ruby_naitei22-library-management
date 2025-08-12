class SessionsController < ApplicationController
  before_action :find_user_and_validate, only: %i(create)
  before_action :check_activated, only: %i(create)
  REMEMBER_ME_SELECTED = "1".freeze

  # GET /login
  def new; end

  # POST /login
  def create
    login_success(@user)
  end

  # DELETE /logout
  def destroy
    log_out
    flash[:success] = t(".success")
    redirect_to root_url, status: :see_other
  end

  # GET /auth/:provider/callback
  def omniauth
    user = User.from_omniauth(request.env["omniauth.auth"])

    if user.persisted?
      handle_successful_oauth(user)
    else
      handle_failed_oauth
    end
  rescue StandardError => e
    handle_oauth_error(e)
  end

  # GET /auth/failure
  def omniauth_failure
    flash[:danger] = t(".oauth_failure")
    redirect_to login_path
  end

  private

  def find_user_and_validate
    @user = User.find_by(email: params.dig(:session, :email)&.downcase)

    return if @user&.authenticate(params.dig(:session, :password))

    login_failed
  end

  def login_failed
    flash.now[:danger] = t(".invalid_email_or_password")
    render :new, status: :unprocessable_entity
  end

  def check_activated
    return if @user.activated_at.present?

    flash[:warning] = t(".not_activated")
    redirect_to root_url, status: :see_other
  end

  def login_success user
    forwarding_url = session[:forwarding_url]
    reset_session
    log_in user
    session[:forwarding_url] = forwarding_url if forwarding_url
    if params.dig(:session,
                  :remember_me) == REMEMBER_ME_SELECTED
      remember user
    else
      remember_session user
    end
    flash[:success] = t(".success")
    redirect_back_or user_path(user), status: :see_other
  end

  def handle_successful_oauth user
    reset_session
    log_in user
    remember_session user

    if user.needs_password_setup?
      redirect_to_password_setup
    else
      redirect_to_user_profile(user)
    end
  end

  def handle_failed_oauth
    flash[:danger] = t(".oauth_error")
    redirect_to login_path
  end

  def handle_oauth_error error
    Rails.logger.error "OAuth error: #{error.message}"
    flash[:danger] = t(".oauth_error")
    redirect_to login_path
  end

  def redirect_to_password_setup
    flash[:info] = t(".setup_password_required")
    redirect_to setup_password_path
  end

  def redirect_to_user_profile user
    flash[:success] = t(".oauth_success")
    redirect_to user_path(user)
  end
end
