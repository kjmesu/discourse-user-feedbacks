# frozen_string_literal: true

class DiscourseUserFeedbacks::UserFeedbacksConstraint
  def matches?(request)
    # Always allow non-GET requests (POST, PUT, DELETE)
    return true if request.request_method != "GET"

    # For GET requests, just check if user is logged in
    current_user = CurrentUser.lookup_from_env(request.env)

    # Allow if user is logged in
    return true if current_user.present?

    # Block anonymous users
    false
  rescue Discourse::InvalidAccess, Discourse::ReadOnly
    false
  end
end
