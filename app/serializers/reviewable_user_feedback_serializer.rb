# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  attributes :type, :feedback_id, :user_id_val, :feedback_to_id, :rating, :review, :reason, :message

  def type
    'ReviewableUserFeedback'
  end

  def feedback_id
    object.payload['feedback_id'] rescue nil
  end

  def user_id_val
    object.payload['user_id'] rescue nil
  end

  def feedback_to_id
    object.payload['feedback_to_id'] rescue nil
  end

  def rating
    object.payload['rating'] rescue nil
  end

  def review
    object.payload['review'] rescue nil
  end

  def reason
    object.payload['reason'] rescue nil
  end

  def message
    object.payload['message'] rescue nil
  end
end
