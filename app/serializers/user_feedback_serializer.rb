# frozen_string_literal: true

class UserFeedbackSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :feedback_to_id,
             :review,
             :rating,
             :created_at,
             :deleted_at,
             :deleted_by,
             :flagged,
             :hidden,
             :hidden_reason_id,
             :hidden_at,
             :review_hidden,
             :reviewable_id,
             :reviewable_score_count,
             :reviewable_score_pending_count,
             :can_delete,
             :can_recover,
             :can_edit,
             :notice

  has_one :user, serializer: GroupPostUserSerializer, embed: :object
  has_one :feedback_to, serializer: GroupPostUserSerializer, embed: :object
  has_one :notice_created_by_user, serializer: BasicUserSerializer, embed: :object

  def notice
    object.custom_fields["feedback_notice"]
  end

  def include_notice?
    notice.present?
  end

  def notice_created_by_user
    return if notice.blank?
    return if notice["created_by_user_id"].blank?
    User.find_by(id: notice["created_by_user_id"])
  end

  def include_notice_created_by_user?
    scope.is_staff? && notice.present? && notice_created_by_user.present?
  end
  end

  def hidden
    object.hidden?
  end

  def reviewable_id
    object.reviewable&.id
  end

  def include_reviewable_id?
    scope.is_staff? && object.reviewable.present?
  end

  def reviewable_score_count
    object.reviewable&.reviewable_scores&.count || 0
  end

  def include_reviewable_score_count?
    include_reviewable_id?
  end

  def reviewable_score_pending_count
    return 0 unless object.reviewable
    object.reviewable.reviewable_scores.select(&:pending?).count
  end

  def include_reviewable_score_pending_count?
    include_reviewable_id?
  end

  def review_hidden
    object.hidden? && !scope.is_staff?
  end

  def include_review_hidden?
    review_hidden
  end

  def review
    if review_hidden
      if scope.current_user && object.user_id == scope.current_user.id
        I18n.t('user_feedbacks.hidden.you_must_edit')
      else
        I18n.t('user_feedbacks.hidden.user_must_edit')
      end
    else
      object.review
    end
  end
end
