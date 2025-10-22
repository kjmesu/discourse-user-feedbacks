# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  attributes :target_created_by, :target_feedback_to

  def target_created_by
    user_id = object.payload&.[]('user_id')
    return nil unless user_id

    user = User.find_by(id: user_id)
    return nil unless user

    BasicUserSerializer.new(user, root: false).as_json
  end

  def target_feedback_to
    feedback_to_id = object.payload&.[]('feedback_to_id')
    return nil unless feedback_to_id

    user = User.find_by(id: feedback_to_id)
    return nil unless user

    BasicUserSerializer.new(user, root: false).as_json
  end

  def include_target_created_by_user?
    false
  end

  def include_created_by_user?
    true
  end

  def created_by_user
    if object.created_by
      BasicUserSerializer.new(object.created_by, root: false)
    end
  end

  def target_url
    nil
  end
end
