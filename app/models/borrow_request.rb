class BorrowRequest < ApplicationRecord
  OVERDUE = "end_date < ? AND status = ?".freeze

  belongs_to :user
  # belongs_to :book
  belongs_to :approved_by_admin, class_name: "User", optional: true
  belongs_to :rejected_by_admin, class_name: "User", optional: true
  belongs_to :returned_by_admin, class_name: "User", optional: true

  has_many :borrow_request_items, dependent: :destroy
  has_many :books, through: :borrow_request_items
  # after_update :restore_book_quantity_if_returned

  enum status: {
    pending: 0,
    approved: 1,
    rejected: 2,
    returned: 3,
    overdue: 4
  }

  scope :overdue_requests, -> {where(OVERDUE, Time.zone.now, :borrowing)}
  validates :request_date, :status, :start_date, :end_date, presence: true
  validates :actual_return_date, presence: true, if: :returned?
  validate :end_date_after_start_date
  validate :admin_note_required_if_rejected, if: :rejected?
  validate :returned_date_required_if_return, if: :returned?
  validate :actual_return_date_cannot_be_future

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    return unless end_date < start_date

    errors.add(:end_date, :after_start_date)
  end

  def admin_note_required_if_rejected
    return unless status == :rejected && admin_note.blank?

    errors.add(:admin_note, :blank_if_rejected)
  end

  def returned_date_required_if_return
    return unless status == :returned && actual_return_date.blank?

    errors.add(:actual_return_date, :blank_if_returned)
  end

  def actual_return_date_cannot_be_future
    unless actual_return_date.present? && actual_return_date > Time.zone.today
      return
    end

    errors.add(:actual_return_date, :cannot_be_future)
  end
end
