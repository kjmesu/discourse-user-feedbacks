# frozen_string_literal: true

class CreateDiscourseUserFeedbacksCustomFields < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_user_feedbacks_custom_fields do |t|
      t.integer :user_feedback_id, null: false
      t.string :name, null: false, limit: 256
      t.text :value
      t.timestamps
    end

    add_index :discourse_user_feedbacks_custom_fields, :user_feedback_id
    add_index :discourse_user_feedbacks_custom_fields, [:user_feedback_id, :name], unique: true
  end
end
