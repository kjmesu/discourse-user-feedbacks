# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  attributes :target_created_by, :target_feedback_to

  # Override target attributes to handle potential nil target
  def target
    return nil unless object.target
    {
      id: object.target.id,
      user_id: object.target.user_id,
      feedback_to_id: object.target.feedback_to_id,
      rating: object.target.rating,
      review: object.target.review,
      created_at: object.target.created_at
    }
  end

  def include_target?
    object.target.present?
  end

  def target_created_by
    return nil unless object.target
    user_id = object.target.user_id || object.payload['user_id']
    return nil unless user_id

    user = User.find_by(id: user_id)
    BasicUserSerializer.new(user, root: false).as_json if user
  end

  def target_feedback_to
    return nil unless object.target
    feedback_to_id = object.target.feedback_to_id || object.payload['feedback_to_id']
    return nil unless feedback_to_id

    user = User.find_by(id: feedback_to_id)
    BasicUserSerializer.new(user, root: false).as_json if user
  end

  def created_by_user
    return nil unless object.created_by
    BasicUserSerializer.new(object.created_by, root: false).as_json
  end

  def target_url
    return nil unless object.target&.id
    "/user_feedbacks/#{object.target.id}"
  end

  def include_target_url?
    object.target&.id.present?
  end
end
