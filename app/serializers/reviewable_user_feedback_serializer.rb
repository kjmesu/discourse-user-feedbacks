# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  attributes :type

  def type
    'ReviewableUserFeedback'
  end

  # Explicitly include payload data
  def payload
    object.payload
  end

  # Define what attributes should be in the payload
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message
end
