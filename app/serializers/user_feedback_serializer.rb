# frozen_string_literal: true

class UserFeedbackSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :feedback_to_id,
             :review,
             :rating,
             :created_at,
             :deleted_at,
             :flagged,
             :hidden,
             :hidden_reason_id,
             :hidden_at,
             :review_hidden

  has_one :user, serializer: GroupPostUserSerializer, embed: :object
  has_one :feedback_to, serializer: GroupPostUserSerializer, embed: :object

  def flagged
    object.flagged?
  end

  def hidden
    object.hidden?
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
