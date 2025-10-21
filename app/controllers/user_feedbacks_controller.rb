# frozen_string_literal: true

module DiscourseUserFeedbacks
  class UserFeedbacksController < ::ApplicationController
    requires_login

    PAGE_SIZE = 30

    def create
      params.require(:rating)
      params.require(:feedback_to_id)
      params.permit(:review)

      rating = params[:rating].to_i
      feedback_to_id = params[:feedback_to_id].to_i

      # Validate rating and feedback_to_id
      raise Discourse::InvalidParameters.new(:rating) if rating < 1 || rating > 5
      raise Discourse::InvalidParameters.new(:feedback_to_id) if feedback_to_id < 1
      raise Discourse::InvalidAccess.new unless feedback_to_id != current_user.id
      raise Discourse::NotFound unless User.exists?(id: feedback_to_id)

      feedback = DiscourseUserFeedbacks::UserFeedback.new(
        user_id: current_user.id,
        feedback_to_id: feedback_to_id,
        rating: rating,
        review: params[:review].presence
      )

      if feedback.save
        render_serialized(feedback, UserFeedbackSerializer)
      else
        render_json_error(feedback.errors.full_messages, status: 422)
      end
    end

    def update
      params.require(:id)
      permitted = params.permit(:rating, :feedback_to_id, :review)

      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])
      # Only allow the author or staff to update feedback
      raise Discourse::InvalidAccess.new unless feedback.user_id == current_user.id || current_user.staff?

      # Validate provided parameters
      if permitted[:rating]
        rating = permitted[:rating].to_i
        raise Discourse::InvalidParameters.new(:rating) if rating < 1 || rating > 5
      end
      if permitted[:feedback_to_id]
        new_feedback_to_id = permitted[:feedback_to_id].to_i
        raise Discourse::InvalidParameters.new(:feedback_to_id) if new_feedback_to_id < 1
        raise Discourse::InvalidAccess.new if new_feedback_to_id == current_user.id
        raise Discourse::NotFound unless User.exists?(id: new_feedback_to_id)
      end

      update_attrs = {}
      update_attrs[:rating] = permitted[:rating] if permitted.key?(:rating)
      update_attrs[:feedback_to_id] = permitted[:feedback_to_id] if permitted.key?(:feedback_to_id)
      update_attrs[:review] = permitted[:review] if permitted.key?(:review)

      if feedback.update(update_attrs)
        render_serialized(feedback, UserFeedbackSerializer)
      else
        render_json_error(feedback.errors.full_messages, status: 422)
      end
    end

    def destroy
      params.require(:id)
      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])
      guardian.ensure_can_delete_feedback!

      feedback.soft_delete!
      render_json_dump(success: true)
    end

    def index
      if params[:feedback_to_id] && params[:feedback_to_id].to_i <= 0
        raise Discourse::InvalidParameters.new(:feedback_to_id)
      end

      page = params[:page].to_i
      page = 1 if page < 1

      feedbacks = DiscourseUserFeedbacks::UserFeedback.includes(:user, :feedback_to)
                                .order(created_at: :desc)
      if params[:feedback_to_id]
        feedbacks = feedbacks.where(feedback_to_id: params[:feedback_to_id].to_i)
      end
      if SiteSetting.user_feedbacks_hide_feedbacks_from_user && !current_user.admin?
        feedbacks = feedbacks.where(user_id: current_user.id)
      end

      total_count = feedbacks.count
      feedbacks_page = feedbacks.offset((page - 1) * PAGE_SIZE).limit(PAGE_SIZE)

      render_json_dump({
        count: total_count,
        feedbacks: serialize_data(feedbacks_page, UserFeedbackSerializer)
      })
    end

    def show
      params.require(:id)
      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])

      if SiteSetting.user_feedbacks_hide_feedbacks_from_user && !current_user.admin? &&
         feedback.feedback_to_id == current_user.id
        raise Discourse::InvalidAccess.new
      end

      render_serialized(feedback, UserFeedbackSerializer)
    end
  end
end
