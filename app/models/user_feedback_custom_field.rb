# frozen_string_literal: true

module DiscourseUserFeedbacks
  class UserFeedbackCustomField < ActiveRecord::Base
    self.table_name = 'discourse_user_feedbacks_custom_fields'

    belongs_to :user_feedback
  end
end
