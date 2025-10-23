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
             :can_recover

  has_one :user, serializer: GroupPostUserSerializer, embed: :object
  has_one :feedback_to, serializer: GroupPostUserSerializer, embed: :object

  def flagged
    object.flagged?
  end

  def deleted_by
    BasicUserSerializer.new(object.deleted_by, root: false).as_json if object.deleted_by
  end

  def include_deleted_by?
    scope.is_staff? && object.deleted_by.present?
  end

  def can_delete
    scope.can_delete_user_feedback?(object)
  end

  def can_recover
    scope.can_recover_user_feedback?(object)
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
