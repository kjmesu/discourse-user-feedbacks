# frozen_string_literal: true
class AddTopicAndPostToUserFeedbacks < ActiveRecord::Migration[7.0]
  def change
    add_column :discourse_user_feedbacks, :topic_id, :integer, null: false
    add_column :discourse_user_feedbacks, :post_id, :integer

    add_index :discourse_user_feedbacks, :topic_id
    add_index :discourse_user_feedbacks, :post_id

    # Conditional unique index based on site setting
    # Note: This will be enforced at the application level via validation
    # since the site setting can be toggled
    add_index :discourse_user_feedbacks,
              [:user_id, :feedback_to_id, :topic_id],
              name: 'index_user_feedbacks_unique_per_topic',
              unique: false  # Not enforced at DB level due to toggleable setting
  end
end
