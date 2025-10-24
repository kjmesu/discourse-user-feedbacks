# frozen_string_literal: true

module DiscourseUserFeedbacks
  class UserFeedback < ActiveRecord::Base
    include Trashable

    self.table_name = 'discourse_user_feedbacks'

    belongs_to :user
    belongs_to :feedback_to, class_name: 'User'
    belongs_to :topic
    belongs_to :post, optional: true
    # belongs_to :deleted_by is provided by Trashable module
    belongs_to :notice_created_by, class_name: 'User', optional: true
    has_one :reviewable, as: :target, class_name: '::ReviewableUserFeedback', dependent: :destroy

    validates :topic_id, presence: true
    validates :rating, presence: true, numericality: { greater_than: 0 }
    validates :feedback_to_id, presence: true, numericality: { greater_than: 0 }
    validate :topic_must_be_valid
    validate :user_must_have_posted_in_topic
    validate :unique_per_topic_if_enabled

    # default_scope is provided by Trashable module
    # trash! and recover! methods are provided by Trashable module

    def hide!(reason_id = nil)
      return if hidden?

      update!(
        hidden: true,
        hidden_at: Time.zone.now,
        hidden_reason_id: reason_id
      )
    end

    def unhide!
      return unless hidden?

      update!(
        hidden: false,
        hidden_at: nil,
        hidden_reason_id: nil
      )
    end

    def hidden?
      hidden
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
      when 'fraudulent'
        ReviewableScore.types[:fraudulent]
      else
        # Use notify_moderators for 'other' and unknown reasons
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
          reason: message.to_s.presence,
          force_review: true
        )
      end
    end

    # Check if feedback should be hidden based on topic or user state
    def should_be_hidden?
      return true if topic.blank?
      return true if topic.deleted_at.present?
      return true if !topic.visible
      return true if topic.closed
      return true if user.suspended?
      return true if feedback_to.suspended?
      false
    end

    private

    def topic_must_be_valid
      return unless topic_id

      topic = Topic.find_by(id: topic_id)

      if topic.nil?
        errors.add(:topic_id, I18n.t('user_feedbacks.errors.topic_must_exist'))
      elsif topic.deleted_at.present?
        errors.add(:topic_id, I18n.t('user_feedbacks.errors.topic_cannot_be_deleted'))
      elsif !topic.visible
        errors.add(:topic_id, I18n.t('user_feedbacks.errors.topic_cannot_be_hidden'))
      elsif topic.closed
        errors.add(:topic_id, I18n.t('user_feedbacks.errors.topic_cannot_be_closed'))
      end
    end

    def user_must_have_posted_in_topic
      return unless topic_id && user_id

      unless Post.exists?(topic_id: topic_id, user_id: user_id)
        errors.add(:base, I18n.t('user_feedbacks.errors.must_have_posted_in_topic'))
      end
    end

    def unique_per_topic_if_enabled
      return unless SiteSetting.user_feedbacks_unique_per_topic
      return unless topic_id && user_id && feedback_to_id

      existing = UserFeedback.where(
        user_id: user_id,
        feedback_to_id: feedback_to_id,
        topic_id: topic_id
      )
      existing = existing.where.not(id: id) if persisted?

      if existing.exists?
        errors.add(:base, I18n.t('user_feedbacks.errors.already_gave_feedback_in_topic'))
      end
    end
  end
end
