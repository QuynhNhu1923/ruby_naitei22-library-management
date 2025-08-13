# app/controllers/admin/borrow_requests_controller.rb
class Admin::BorrowRequestsController < ApplicationController
  include Pagy::Backend
  helper_method :status_class

  before_action :require_admin
  before_action :set_borrow_request, only: %i(show edit_status change_status)

  def index
    auto_update_overdue_requests
    @pagy, @borrow_requests = pagy(
      BorrowRequest.includes(:user).order(created_at: :desc)
    )
  end

  def show; end

  def edit_status
    render partial: "status_form", formats: [:html],
           locals: {borrow_request: @borrow_request}
  end

  def change_status
    prev_status = @borrow_request.status
    new_status  = borrow_request_params[:status].to_sym

    return handle_no_change if new_status == prev_status

    BorrowRequest.transaction do
      @borrow_request.update!(
        borrow_request_params.merge(status_extra_attributes(prev_status,
                                                            new_status))
      )
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
    if prev_status != :approved
      attrs[:approved_by_admin_id] = current_user.id
      decrement_book_stock
    end
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
    }.tap {increment_book_stock}
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

  # AUTO OVERDUE
  def auto_update_overdue_requests
    BorrowRequest.where(status: :approved)
                 .where(BorrowRequest.arel_table[:end_date].lt(Time.zone.today))
                 .update_all(status: :overdue)
  end

  def set_borrow_request
    @borrow_request = BorrowRequest.find_by(id: params[:id])
  end

  def require_admin
    redirect_to root_path unless current_user&.admin?
  end
end
