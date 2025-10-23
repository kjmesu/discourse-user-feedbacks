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

      # Map flag reasons to score types
      score_type = case reason
      when 'inappropriate'
        ReviewableScore.types[:inappropriate]
      when 'fraudulent_transaction'
        ReviewableScore.types[:fraudulent_transaction]
      else
        # Use notify_moderators for 'other' and unknown reasons
        ReviewableScore.types[:notify_moderators]
      end

      # Build the reason text that will appear in the review queue
      reason_text = case reason
      when 'inappropriate'
        I18n.t('flagging.inappropriate.title')
      when 'fraudulent_transaction'
        I18n.t('user_feedbacks.flag_reasons.fraudulent_transaction')
      when 'other'
        I18n.t('flagging.notify_action')
      else
        'Flagged for review'
      end

      # Add the custom message if provided
      reason_text = [reason_text, message].compact.join(': ') if message.present?

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
          reason: reason_text,
          force_review: true
        )
      end
    end
  end
end
