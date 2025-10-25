# frozen_string_literal: true

module DiscourseUserFeedbacks
  class UserFeedbacksController < ::ApplicationController
    requires_login

    PAGE_SIZE = 30

    def create
      params.require([:rating, :feedback_to_id, :topic_id])
      params.permit(:review, :post_id)

      raise Discourse::InvalidParameters.new(:rating) if params[:rating].to_i <= 0
      raise Discourse::InvalidParameters.new(:feedback_to_id) if params[:feedback_to_id].to_i <= 0
      raise Discourse::InvalidParameters.new(:topic_id) if params[:topic_id].to_i <= 0

      topic = Topic.find_by(id: params[:topic_id])
      raise Discourse::NotFound unless topic

      post = params[:post_id] ? Post.find_by(id: params[:post_id]) : nil
      feedback_to_user = User.find_by(id: params[:feedback_to_id])
      raise Discourse::NotFound unless feedback_to_user

      guardian.ensure_can_create_feedback_for_user_in_topic!(feedback_to_user, topic, post)

      opts = {
        rating: params[:rating],
        feedback_to_id: params[:feedback_to_id],
        topic_id: params[:topic_id],
        user_id: current_user.id
      }

      opts[:review] = params[:review] if params.has_key?(:review) && params[:review]
      opts[:post_id] = params[:post_id] if params[:post_id]

      feedback = DiscourseUserFeedbacks::UserFeedback.create!(opts)

      create_feedback_notification(feedback)

      render_serialized(feedback, UserFeedbackSerializer)
    rescue ActiveRecord::RecordInvalid => e
      render_json_error(e.record.errors.full_messages.join(', '), status: 422)
    end

    def update
      params.require(:id)
      params.permit(:rating, :feedback_to_id, :review, :notice)

      feedback = DiscourseUserFeedbacks::UserFeedback.find(params[:id])

      opts = {}

      if params.has_key?(:rating)
        raise Discourse::InvalidParameters.new(:rating) if params[:rating].to_i <= 0
        opts[:rating] = params[:rating]
      end

      if params.has_key?(:review)
        opts[:review] = params[:review]
      end

      if params.has_key?(:notice)
        guardian.ensure_can_edit_user_feedback!(feedback)
        if params[:notice].present?
          cooked = PrettyText.cook(params[:notice])
          opts[:notice] = { type: "custom", raw: params[:notice], cooked: cooked }
          opts[:notice_created_by_id] = current_user.id
        else
          opts[:notice] = nil
          opts[:notice_created_by_id] = nil
        end
      end

      feedback.update!(opts)

      render_serialized(feedback, UserFeedbackSerializer)
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

      # Filter out feedbacks that should be hidden based on topic/user state
      # (unless user is staff - they can see everything)
      unless current_user&.staff?
        feedbacks = feedbacks.select { |f| !f.should_be_hidden? }
      end

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

    private

    def create_feedback_notification(feedback)
      # Check if the feedback receiver has already left feedback for the giver in this topic
      reciprocal_feedback_exists = DiscourseUserFeedbacks::UserFeedback.exists?(
        user_id: feedback.feedback_to_id,
        feedback_to_id: feedback.user_id,
        topic_id: feedback.topic_id
      )

      # Build the PM message
      stars = "⭐" * feedback.rating
      message_body = if reciprocal_feedback_exists
        I18n.t('user_feedbacks.pm_notification',
          display_username: feedback.user.username,
          rating: feedback.rating,
          stars: stars,
          topic_title: feedback.topic.title,
          topic_url: feedback.topic.url
        )
      else
        I18n.t('user_feedbacks.pm_notification_with_reciprocation',
          display_username: feedback.user.username,
          rating: feedback.rating,
          stars: stars,
          topic_title: feedback.topic.title,
          topic_url: feedback.topic.url
        )
      end

      # Create a private message using PostCreator
      PostCreator.create!(
        Discourse.system_user,
        title: I18n.t('user_feedbacks.pm_title', username: feedback.user.username),
        raw: message_body,
        archetype: Archetype.private_message,
        target_usernames: User.find(feedback.feedback_to_id).username,
        skip_validations: true
      )
    end
  end
end
