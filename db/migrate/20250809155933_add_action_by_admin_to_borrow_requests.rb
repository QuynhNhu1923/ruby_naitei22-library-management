class AddActionByAdminToBorrowRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :borrow_requests, :rejected_by_admin_id, :integer
    add_column :borrow_requests, :returned_by_admin_id, :integer
  end
end
