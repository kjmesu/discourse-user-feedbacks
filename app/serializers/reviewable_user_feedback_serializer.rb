# frozen_string_literal: true

class ReviewableUserFeedbackSerializer < ReviewableSerializer
  payload_attributes :feedback_id, :user_id, :feedback_to_id, :rating, :review, :reason, :message

  def attributes
    hash = super

    # Debug: Check what's in the hash
    Rails.logger.info("=== ReviewableUserFeedbackSerializer#attributes ===")
    Rails.logger.info("_payload_for_serialization: #{self.class._payload_for_serialization.inspect}")
    Rails.logger.info("Object payload: #{object.payload.inspect}")
    Rails.logger.info("Hash keys: #{hash.keys.inspect}")
    Rails.logger.info("Hash[:payload]: #{hash[:payload].inspect}")
    Rails.logger.info("Full hash: #{hash.inspect}")
    Rails.logger.info("=== End Serializer ===")

    hash
  end
end
