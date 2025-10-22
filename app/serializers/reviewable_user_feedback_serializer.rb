# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  # Override these to prevent association errors
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
