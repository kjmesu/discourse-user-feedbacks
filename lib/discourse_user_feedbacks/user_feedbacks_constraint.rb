# frozen_string_literal: true

class DiscourseUserFeedbacks::UserFeedbacksConstraint
  def matches?(request)
    return true if request.request_method != "GET"

    current_user = CurrentUser.lookup_from_env(request.env)

    # All logged-in users can view feedback
    return true if current_user

    false
  rescue Discourse::InvalidAccess, Discourse::ReadOnly
    false
  end
end
