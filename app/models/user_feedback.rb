# frozen_string_literal: true

module DiscourseUserFeedbacks
  class UserFeedback < ActiveRecord::Base
    self.table_name = 'discourse_user_feedbacks'

    belongs_to :user
    belongs_to :feedback_to, class_name: 'User'

    default_scope { where(deleted_at: nil) }

    def soft_delete!
      update!(deleted_at: Time.zone.now)
    end
  end
end
