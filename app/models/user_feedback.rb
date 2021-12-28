# frozen_string_literal: true

module DiscourseUserScores
  class UserFeedback < ActiveRecord::Base
    self.table_name = 'discourse_user_feedbacks'

    belongs_to :user
    belongs_to :feedback_to, class_name: 'User'

    default_scope { where(deleted_at: nil) }
  end
end
