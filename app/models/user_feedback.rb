# frozen_string_literal: true

module DiscourseUserFeedbacks
  class UserFeedback < ActiveRecord::Base
    self.table_name = 'discourse_user_feedbacks'

    belongs_to :user
    belongs_to :feedback_to, class_name: 'User'

    default_scope { where(deleted_at: nil) }

    # Soft-delete feedback by setting deleted_at
    def soft_delete!
      update!(deleted_at: Time.zone.now)
    end

    # Validations to ensure data integrity
    validates :user_id, presence: true
    validates :feedback_to_id, presence: true, uniqueness: { scope: :user_id }
    validates :rating, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  end
end
