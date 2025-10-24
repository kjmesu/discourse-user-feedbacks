# frozen_string_literal: true

class RemoveNoticeFromUserFeedbacks < ActiveRecord::Migration[7.0]
  def change
    remove_column :discourse_user_feedbacks, :notice, :jsonb
    remove_column :discourse_user_feedbacks, :notice_created_by_id, :integer
  end
end
