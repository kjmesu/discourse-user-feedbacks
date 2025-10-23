# frozen_string_literal: true

class AddNoticeToUserFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :user_feedbacks, :notice, :jsonb
    add_column :user_feedbacks, :notice_created_by_id, :integer

    add_index :user_feedbacks, :notice_created_by_id
  end
end
