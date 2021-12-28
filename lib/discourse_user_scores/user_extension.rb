# frozen_string_literal: true

module DiscourseRewards::UserExtension
  def self.prepended(base)
    base.has_many :feedbacks, class_name: 'DiscourseUserScores::UserFeedback'
  end
end
