# frozen_string_literal: true

class AddReviewableSupportToUserFeedbacks < ActiveRecord::Migration[7.0]
  def change
    # No schema changes needed - Reviewable uses polymorphic association via target_type and target_id
    # which are already part of the reviewables table in Discourse core
  end
end
