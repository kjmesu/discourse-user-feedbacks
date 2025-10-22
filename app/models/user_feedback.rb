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

      payload_data = {
        feedback_id: id,
        user_id: user_id,
        feedback_to_id: feedback_to_id,
        rating: rating,
        review: review,
        reason: reason || 'inappropriate',
        message: message
      }

      Rails.logger.info("=== Creating ReviewableUserFeedback ===")
      Rails.logger.info("Payload data: #{payload_data.inspect}")

      reviewable = ::ReviewableUserFeedback.needs_review!(
        target: self,
        created_by: created_by_user,
        reviewable_by_moderator: true,
        payload: payload_data
      )

      Rails.logger.info("Created reviewable ID: #{reviewable.id}")
      Rails.logger.info("Reviewable payload after save: #{reviewable.payload.inspect}")

      reviewable
    end
  end
end
