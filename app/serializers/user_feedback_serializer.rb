# frozen_string_literal: true

class UserFeedbackSerializer < ApplicationSerializer
  attributes :id,
             :user_id,
             :feedback_to_id,
             :review,
             :rating,
             :created_at,
             :deleted_at,
             :flagged

  has_one :user, serializer: GroupPostUserSerializer, embed: :object
  has_one :feedback_to, serializer: GroupPostUserSerializer, embed: :object

  def flagged
    object.flagged?
  end
end
