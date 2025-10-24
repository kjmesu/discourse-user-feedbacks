# frozen_string_literal: true

class AddDeletedByIdToUserFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :discourse_user_feedbacks, :deleted_by_id, :integer, null: true
    add_index :discourse_user_feedbacks, :deleted_by_id
  end
end
