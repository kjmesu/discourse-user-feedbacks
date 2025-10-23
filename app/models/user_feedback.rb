# frozen_string_literal: true

module DiscourseUserFeedbacks
  class UserFeedback < ActiveRecord::Base
    self.table_name = 'discourse_user_feedbacks'

    belongs_to :user
    belongs_to :feedback_to, class_name: 'User'
    has_one :reviewable, as: :target, class_name: '::ReviewableUserFeedback', dependent: :destroy

    default_scope { where(deleted_at: nil) }

    def soft_delete!
      update!(deleted_at: Time.zone.now)
    end

    def flagged?
      reviewable.present? && reviewable.pending?
    end

    def flag_for_review!(created_by_user, reason: nil, message: nil)
      return reviewable if flagged?

      score_type = case reason
      when 'inappropriate'
        ReviewableScore.types[:inappropriate]
      when 'fraudulent_transaction'
        ReviewableScore.types[:spam]
      else
        ReviewableScore.types[:notify_moderators]
      end

      ::ReviewableUserFeedback.needs_review!(
        target: self,
        created_by: created_by_user,
        reviewable_by_moderator: true,
        payload: {
          'feedback_id' => id,
          'user_id' => user_id,
          'feedback_to_id' => feedback_to_id,
          'rating' => rating,
          'review' => review,
          'reason' => reason || 'inappropriate',
          'message' => message
        }
      ).tap do |reviewable|
        reviewable.add_score(
          created_by_user,
          score_type,
          reason: message,
          force_review: true
        )
      end
    end
  end
end
