# app/controllers/admin/borrow_requests_controller.rb
class Admin::BorrowRequestsController < ApplicationController
  include Pagy::Backend
  helper_method :status_class

  before_action :require_admin
  before_action :set_borrow_request, only: %i(show edit_status change_status)

  # GET /admin/borrow_requests
  def index
    @pagy, @borrow_requests = pagy(
      BorrowRequest.includes(:user).sorted
    )
  end

  # GET /admin/borrow_requests/:id
  def show; end

  # GET /admin/borrow_requests/:id/edit_status
  def edit_status
    render partial: "status_form", formats: [:html],
           locals: {borrow_request: @borrow_request}
  end

  # PATCH /admin/borrow_requests/:id/change_status
  def change_status
    prev_status = @borrow_request.status.to_sym
    new_status  = borrow_request_params[:status].to_sym

    return handle_no_change if new_status == prev_status

    BorrowRequest.transaction do
      @borrow_request.update!(
        borrow_request_params.merge(status_extra_attributes(prev_status,
                                                            new_status))
      )
      case new_status
      when :approved
        decrement_book_stock if prev_status != :approved
      when :returned
        increment_book_stock if prev_status != :returned
      end
    end

    @borrow_request.reload
    respond_to_success
  rescue ActiveRecord::RecordInvalid => e
    handle_update_error(e)
  end

  private

  def borrow_request_params
    params.fetch(:borrow_request, {}).permit(:status, :admin_note,
                                             :actual_return_date)
  end

  def handle_no_change
    @borrow_request.errors.add(:status, t(".no_change"))
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "status_form_#{@borrow_request.id}",
          partial: "status_form",
          formats: [:html],
          locals: {borrow_request: @borrow_request}
        ), status: :unprocessable_entity
      end
      format.html do
        redirect_to admin_borrow_request_path(@borrow_request),
                    alert: t(".no_change")
      end
    end
  end

  def status_extra_attributes prev_status, new_status
    case new_status
    when :approved
      approved_attributes(prev_status)
    when :rejected
      rejected_attributes
    when :returned
      returned_attributes
    else
      {}
    end
  end

  def approved_attributes prev_status
    attrs = {
      rejected_by_admin_id: nil
    }
    attrs[:approved_by_admin_id] = current_user.id if prev_status != :approved
    attrs
  end

  def rejected_attributes
    {
      rejected_by_admin_id: current_user.id,
      approved_by_admin_id: nil
    }
  end

  def returned_attributes
    validate_actual_return_date!(borrow_request_params[:actual_return_date])
    {
      returned_by_admin_id: current_user.id,
      actual_return_date:
        borrow_request_params[:actual_return_date].presence || Time.current
    }
  end

  def respond_to_success
    respond_to do |format|
      format.turbo_stream
      format.html do
        redirect_to admin_borrow_request_path(@borrow_request),
                    success: t(".status_updated")
      end
    end
  end

  def handle_update_error exception
    @borrow_request.errors.add(:base, exception.message)
    respond_to do |format|
      format.turbo_stream do
        render partial: "status_form",
               formats: [:html],
               locals: {borrow_request: @borrow_request},
               status: :unprocessable_entity
      end
    end
  end

  def validate_actual_return_date! date_str
    return if date_str.blank?

    date = begin
      Date.parse(date_str)
    rescue StandardError
      nil
    end
    unless date
      raise ActiveRecord::RecordInvalid.new(@borrow_request),
            t(".invalid_format")
    end
    return unless date > Time.zone.today

    raise ActiveRecord::RecordInvalid.new(@borrow_request), t(".future_date")
  end

  # === STOCK METHODS ===
  def decrement_book_stock
    @borrow_request.borrow_request_items.each do |item|
      item.book.decrement!(:available_quantity, item.quantity)
    end
  end

  def increment_book_stock
    @borrow_request.borrow_request_items.each do |item|
      item.book.increment!(:available_quantity, item.quantity)
    end
  end

  def set_borrow_request
    @borrow_request = BorrowRequest.find_by(id: params[:id])
  end

  def require_admin
    return if current_user&.admin?

    flash[:alert] = t(".flash.no_access")
    redirect_to root_path
  end
end
