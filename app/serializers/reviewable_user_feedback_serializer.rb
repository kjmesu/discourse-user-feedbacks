# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  target_attributes :id, :user_id, :feedback_to_id, :rating, :review, :created_at
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  def created_by_user
    BasicUserSerializer.new(object.created_by, root: false).as_json
  end

  def target_url
    "/user_feedbacks/#{object.target.id}"
  end
end
