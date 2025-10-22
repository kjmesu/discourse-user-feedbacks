# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  attributes :target_created_by

  def target_created_by
    BasicUserSerializer.new(object.target&.user, scope: scope, root: false).as_json
  end

  def include_target_created_by?
    object.target&.user.present?
  end
end
