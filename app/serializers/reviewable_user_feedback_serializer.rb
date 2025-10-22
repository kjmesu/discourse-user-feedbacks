# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  target_attributes :id, :user_id, :feedback_to_id, :rating, :review, :created_at
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  attributes :target_created_by, :target_feedback_to

  def target_created_by
    if object.target&.user
      BasicUserSerializer.new(object.target.user, root: false).as_json
    end
  end

  def target_feedback_to
    if object.target&.feedback_to
      BasicUserSerializer.new(object.target.feedback_to, root: false).as_json
    end
  end

  def created_by_user
    BasicUserSerializer.new(object.created_by, root: false).as_json
  end

  def target_url
    "/user_feedbacks/#{object.target.id}"
  end
end
