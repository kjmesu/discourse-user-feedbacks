# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  def attributes
    hash = super
    Rails.logger.info("=== ReviewableUserFeedbackSerializer#attributes ===")
    Rails.logger.info("Object class: #{object.class}")
    Rails.logger.info("Object ID: #{object.id}")
    Rails.logger.info("Object type: #{object.type}")
    Rails.logger.info("Raw payload: #{object.payload.inspect}")
    Rails.logger.info("Serialized hash: #{hash.inspect}")
    Rails.logger.info("=== End Serializer ===")
    hash
  end
end
