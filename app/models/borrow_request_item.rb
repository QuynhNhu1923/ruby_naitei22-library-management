class BorrowRequestItem < ApplicationRecord
  belongs_to :borrow_request
  belongs_to :book

  delegate :title, :publication_year, :image, to: :book, prefix: true
  delegate :name, to: :book_author, prefix: true

  private

  def book_author
    book.author
  end
end
