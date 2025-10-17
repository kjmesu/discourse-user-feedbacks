# frozen_string_literal: true

module DiscourseUserFeedbacks
  class UserFeedbacksController < ::ApplicationController
    requires_login

    PAGE_SIZE = 30

    def create
      params.require([:rating, :feedback_to_id])
      params.permit(:review)

      raise Discourse::InvalidParameters.new(:rating) if params[:rating].to_i <= 0
      raise Discourse::InvalidParameters.new(:feedback_to_id) if params[:feedback_to_id].to_i <= 0

      opts = {
        rating: params[:rating],
        feedback_to_id: params[:feedback_to_id]
      }

      opts[:review] = params[:review] if params.has_key?(:review) && params[:review]

      opts[:user_id] = current_user.id

      feedback = DiscourseUserFeedbacks::UserFeedback.create(opts)

      render_serialized(feedback, UserFeedbackSerializer)
    end

    def update
      params.require(:id).permit(:rating, :feedback_to_id, :review)

      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])

      opts = {
        rating: params[:rating],
        feedback_to_id: params[:feedback_to_id]
      }

      raise Discourse::InvalidParameters.new(:rating) if params[:rating] && params[:rating].to_i <= 0

      opts[:rating] = params[:rating] if params.has_key?(:rating) && params[:rating]
      opts[:review] = params[:review] if params.has_key?(:review) && params[:review]
      opts[:user_id] = current_user.id

      feedback.update!(opts)

      render_serialized(feedback, UserFeedbackSerializer)
    end

    def destroy
      params.require(:id)
      guardian.ensure_can_delete_feedback!

      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])

      feedback.update!(deleted_at: Time.zone.now)

      render_json_dump(success: true)
    end

    def index
      raise Discourse::InvalidParameters.new(:feedback_to_id) if params.has_key?(:feedback_to_id) && params[:feedback_to_id].to_i <= 0

      page = params[:page].to_i || 1

      feedbacks = DiscourseUserFeedbacks::UserFeedback.order(created_at: :desc)

      feedbacks = feedbacks.where(feedback_to_id: params[:feedback_to_id]) if params[:feedback_to_id]

      feedbacks = feedbacks.where(user_id: current_user.id) if SiteSetting.user_feedbacks_hide_feedbacks_from_user && !current_user.admin

      count = feedbacks.length

      feedbacks = feedbacks.offset(page * PAGE_SIZE).limit(PAGE_SIZE)

      render_json_dump({ count: count, feedbacks: serialize_data(feedbacks, UserFeedbackSerializer) })
    end

    def show
      params.require(:id)

      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])

      render_serialized(feedback, UserFeedbackSerializer)
    end
  end
end
