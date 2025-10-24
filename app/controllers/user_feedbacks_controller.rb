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
      params.require(:id)
      params.permit(:rating, :feedback_to_id, :review)

      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])

      opts = {}

      if params.has_key?(:rating)
        raise Discourse::InvalidParameters.new(:rating) if params[:rating].to_i <= 0
        opts[:rating] = params[:rating]
      end

      if params.has_key?(:review)
        opts[:review] = params[:review]
      end

      feedback.update!(opts)

      render_serialized(feedback, UserFeedbackSerializer)
    end

    def notice
      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])
      guardian.ensure_can_edit_user_feedback!(feedback)

      if params[:notice].present?
        cooked_notice = PrettyText.cook(params[:notice])
        feedback.custom_fields["feedback_notice"] = {
          type: "custom",
          raw: params[:notice],
          cooked: cooked_notice,
          created_by_user_id: current_user.id,
        }
      else
        feedback.custom_fields.delete("feedback_notice")
      end

      feedback.save_custom_fields

      render json: { cooked_notice: feedback.custom_fields["feedback_notice"]&.[]("cooked") }
    end

    def destroy
      params.require(:id)

      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])
      guardian.ensure_can_delete_user_feedback!(feedback)

      # Use Discourse's native Trashable method
      feedback.trash!(current_user)

      render_json_dump(success: true)
    end

    def recover
      params.require(:id)

      feedback = DiscourseUserFeedbacks::UserFeedback.with_deleted.find(params[:id])
      guardian.ensure_can_recover_user_feedback!(feedback)

      # Use Discourse's native Trashable method
      feedback.recover!

      render_serialized(feedback, UserFeedbackSerializer)
    end

    def unhide
      params.require(:id)

      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])
      guardian.ensure_can_edit_user_feedback!(feedback)

      feedback.unhide!

      render_serialized(feedback, UserFeedbackSerializer)
    end


    def index
      raise Discourse::InvalidParameters.new(:feedback_to_id) if params.has_key?(:feedback_to_id) && params[:feedback_to_id].to_i <= 0

      page = params[:page].to_i || 1

      # Staff can see deleted feedback, regular users cannot (Trashable default_scope)
      feedbacks = if current_user&.staff?
        DiscourseUserFeedbacks::UserFeedback.with_deleted.order(created_at: :desc)
      else
        DiscourseUserFeedbacks::UserFeedback.order(created_at: :desc)
      end

      feedbacks = feedbacks.where(feedback_to_id: params[:feedback_to_id]) if params[:feedback_to_id]

      feedbacks = feedbacks.where(user_id: current_user.id) if SiteSetting.user_feedbacks_hide_feedbacks_from_user && !current_user.admin

      count = feedbacks.length

      feedbacks = feedbacks.offset(page * PAGE_SIZE).limit(PAGE_SIZE)

      render_json_dump({ count: count, feedbacks: serialize_data(feedbacks, UserFeedbackSerializer) })
    end

    def show
      params.require(:id)

      # Staff can view deleted feedback
      feedback = if current_user&.staff?
        DiscourseUserFeedbacks::UserFeedback.with_deleted.find(params[:id])
      else
        DiscourseUserFeedbacks::UserFeedback.find(params[:id])
      end

      render_serialized(feedback, UserFeedbackSerializer)
    end

    def flag
      params.require(:id)
      params.permit(:reason, :message)

      feedback = DiscourseUserFeedbacks::UserFeedback.unscoped.find(params[:id])
      guardian.ensure_can_flag_user_feedback!(feedback)

      reviewable = feedback.flag_for_review!(
        current_user,
        reason: params[:reason] || 'inappropriate',
        message: params[:message]
      )

      render_json_dump(
        success: true,
        reviewable_id: reviewable.id,
        message: I18n.t('user_feedbacks.flag.success')
      )
    rescue Discourse::InvalidAccess => e
      render_json_error(e.message, status: 403)
    rescue => e
      render_json_error(e.message, status: 500)
    end
  end
end
