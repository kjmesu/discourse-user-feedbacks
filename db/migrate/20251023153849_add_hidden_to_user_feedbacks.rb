# frozen_string_literal: true

class AddHiddenToUserFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :discourse_user_feedbacks, :hidden, :boolean, default: false, null: false
    add_column :discourse_user_feedbacks, :hidden_at, :datetime
    add_column :discourse_user_feedbacks, :hidden_reason_id, :integer
  end
end
