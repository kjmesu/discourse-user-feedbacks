# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  has_one :target_created_by, embed: :objects, serializer: BasicUserSerializer

  def target_created_by
    object.target&.user
  end

  def include_target_created_by?
    object.target&.user.present?
  end
end
