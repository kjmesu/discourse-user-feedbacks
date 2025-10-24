# frozen_string_literal: true
# name: discourse-user-feedbacks
# about: allow user to give feedback to fellow users
# version: 1.0.0
# authors: Ahmed Gagan
# url: https://github.com/Ahmedgagan/discourse-user-feedbacks

enabled_site_setting :user_feedbacks_enabled

if respond_to?(:register_svg_icon)
  register_svg_icon "fas fa-star"
end

register_asset 'stylesheets/user-feedbacks.scss'

after_initialize do
  module ::DiscourseUserFeedbacks
    PLUGIN_NAME ||= 'discourse-user-feedbacks'

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseUserFeedbacks
    end
  end

  [
    "../app/controllers/user_feedbacks_controller.rb",
    "../app/serializers/user_feedback_serializer.rb",
    "../app/serializers/reviewable_user_feedback_serializer.rb",
    "../app/models/user_feedback.rb",
    "../app/models/reviewable_user_feedback.rb",
    "../lib/discourse_user_feedbacks/user_extension.rb",
    "../lib/discourse_user_feedbacks/user_feedbacks_constraint.rb",
    "../config/routes"
  ].each { |path| require File.expand_path(path, __FILE__) }

  # Register custom reviewable score types for feedback flags
  ReviewableScore.add_new_types([:fraudulent])

  # Register the reviewable type with this plugin
  register_reviewable_type ReviewableUserFeedback

  Discourse::Application.routes.append do
    %w{users u}.each do |root_path|
      get "#{root_path}/:username/feedbacks" => "users#preferences", constraints: { username: RouteFormat.username }
    end

    get "/feedbacks/*path" => "list#latest"
    
    mount ::DiscourseUserFeedbacks::Engine, at: '/'
  end

  reloadable_patch do |plugin|
    User.class_eval { prepend DiscourseUserFeedbacks::UserExtension }
  end

  add_to_serializer(:basic_user, :feedbacks_to) do
    user = object
    user = object[:user] if object.class != User

    return nil if !user

    return nil if !user.feedbacks

    user.feedbacks.pluck(:feedback_to_id)
  end

  add_to_serializer(:basic_user, :average_rating) do
    user = object
    user = object[:user] if object.class != User

    return nil if !user

    # Only count non-hidden feedbacks
    feedbacks = DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id, hidden: false)
    count = feedbacks.count
    return 0.0 if count == 0
    feedbacks.average(:rating).to_f
  end

  add_to_serializer(:basic_user, :rating_count) do
    user = object
    user = object[:user] if object.class != User

    return nil if !user

    # Only count non-hidden feedbacks
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id, hidden: false).count
  end

  add_to_serializer(:post, :user_average_rating) do
    user = object.user
    # Only count non-hidden feedbacks
    feedbacks = DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id, hidden: false)
    count = feedbacks.count
    return 0.0 if count == 0
    feedbacks.average(:rating).to_f
  end

  add_to_serializer(:post, :user_rating_count) do
    # Only count non-hidden feedbacks
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: object.user.id, hidden: false).count
  end

  # Auto-hide/show feedbacks when topic state changes
  on(:topic_status_updated) do |topic, status, enabled|
    # When a topic is closed, deleted, or made invisible, hide associated feedbacks
    if ['closed', 'autoclosed', 'archived', 'visible'].include?(status)
      feedbacks = DiscourseUserFeedbacks::UserFeedback.where(topic_id: topic.id)
      feedbacks.each do |feedback|
        if feedback.should_be_hidden? && !feedback.hidden?
          feedback.hide!
        elsif !feedback.should_be_hidden? && feedback.hidden?
          feedback.unhide!
        end
      end
    end
  end

  # Auto-hide/show feedbacks when user is suspended/unsuspended
  on(:user_suspended) do |args|
    user = args[:user]
    # Hide feedbacks given by suspended user
    DiscourseUserFeedbacks::UserFeedback.where(user_id: user.id).each do |feedback|
      feedback.hide! unless feedback.hidden?
    end
    # Hide feedbacks received by suspended user
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).each do |feedback|
      feedback.hide! unless feedback.hidden?
    end
  end

  on(:user_unsuspended) do |args|
    user = args[:user]
    # Unhide feedbacks that should no longer be hidden
    given_feedbacks = DiscourseUserFeedbacks::UserFeedback.where(user_id: user.id)
    received_feedbacks = DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id)

    (given_feedbacks + received_feedbacks).uniq.each do |feedback|
      if !feedback.should_be_hidden? && feedback.hidden?
        feedback.unhide!
      end
    end
  end

  Guardian.class_eval do
    def can_delete_feedback?
      user&.staff?
    end

    def ensure_can_delete_feedback!
      raise Discourse::InvalidAccess.new unless can_delete_feedback?
    end

    def can_flag_user_feedback?(feedback)
      return false unless authenticated?
      return false if feedback.user_id == user.id # Can't flag own feedback
      return false if feedback.flagged? # Already flagged
      true
    end

    def ensure_can_flag_user_feedback!(feedback)
      raise Discourse::InvalidAccess.new unless can_flag_user_feedback?(feedback)
    end

    def can_delete_user_feedback?(feedback)
      user&.staff?
    end

    def can_edit_user_feedback?(feedback)
      # Staff members can edit any feedback
      user&.staff?
    end

    def can_recover_user_feedback?(feedback)
      return false unless feedback
      return false unless feedback.deleted_at

      # Staff can always recover deleted feedback
      return true if user&.staff?

      # Users can recover their own deleted feedback
      return true if is_my_own_feedback?(feedback)

      false
    end

    def ensure_can_recover_user_feedback!(feedback)
      raise Discourse::InvalidAccess.new unless can_recover_user_feedback?(feedback)
    end

    def can_create_feedback_for_user_in_topic?(feedback_to_user, topic, post = nil)
      Rails.logger.info "=== Feedback Permission Check ==="
      Rails.logger.info "Current user: #{user&.id} (#{user&.username})"
      Rails.logger.info "Authenticated: #{authenticated?}"
      Rails.logger.info "Feedback to: #{feedback_to_user&.id} (#{feedback_to_user&.username})"
      Rails.logger.info "Topic: #{topic&.id} (creator: #{topic&.user_id})"
      Rails.logger.info "Post: #{post&.id} (number: #{post&.post_number})"

      unless authenticated?
        Rails.logger.info "FAIL: User not authenticated"
        return false
      end

      unless topic
        Rails.logger.info "FAIL: No topic provided"
        return false
      end

      if feedback_to_user.id == user.id
        Rails.logger.info "FAIL: Cannot give feedback to yourself"
        return false
      end

      # Topic must be valid
      if topic.deleted_at.present?
        Rails.logger.info "FAIL: Topic is deleted (deleted_at: #{topic.deleted_at})"
        return false
      end

      if !topic.visible
        Rails.logger.info "FAIL: Topic is not visible"
        return false
      end

      if topic.closed
        Rails.logger.info "FAIL: Topic is closed"
        return false
      end

      # User must have posted in the topic
      user_has_posted = Post.exists?(topic_id: topic.id, user_id: user.id)
      Rails.logger.info "User has posted in topic: #{user_has_posted}"
      unless user_has_posted
        Rails.logger.info "FAIL: User has not posted in this topic"
        return false
      end

      # Check if user is the topic creator
      is_topic_creator = topic.user_id == user.id
      Rails.logger.info "Is topic creator: #{is_topic_creator}"

      if is_topic_creator
        # Topic creator can give feedback to any participant (except themselves)
        # on any post except post #1
        if post && post.post_number == 1
          Rails.logger.info "FAIL: Topic creator cannot rate on post #1"
          return false
        end
        target_has_posted = Post.exists?(topic_id: topic.id, user_id: feedback_to_user.id)
        Rails.logger.info "Target has posted: #{target_has_posted}"
        if target_has_posted
          Rails.logger.info "SUCCESS: Topic creator can rate participant who has posted"
          return true
        else
          Rails.logger.info "FAIL: Target user has not posted in topic"
          return false
        end
      else
        # Non-creators can give feedback to the topic creator on ANY of the topic creator's posts
        unless topic.user_id == feedback_to_user.id
          Rails.logger.info "FAIL: Non-creator trying to rate non-OP (target=#{feedback_to_user.id}, OP=#{topic.user_id})"
          return false
        end

        # Verify the post being rated belongs to the topic creator
        if post && post.user_id != topic.user_id
          Rails.logger.info "FAIL: Post does not belong to topic creator (post.user_id=#{post.user_id}, topic.user_id=#{topic.user_id})"
          return false
        end

        Rails.logger.info "SUCCESS: Non-creator can rate OP on their post"
        true
      end
    end

    def ensure_can_create_feedback_for_user_in_topic!(feedback_to_user, topic, post = nil)
      unless can_create_feedback_for_user_in_topic?(feedback_to_user, topic, post)
        # Build diagnostic message
        diagnostic = []
        diagnostic << "Current user: #{user&.id}"
        diagnostic << "Feedback to: #{feedback_to_user&.id}"
        diagnostic << "Topic ID: #{topic&.id}, Creator: #{topic&.user_id}"
        diagnostic << "Post ID: #{post&.id}, Post #: #{post&.post_number}"
        diagnostic << "User authenticated: #{authenticated?}"
        diagnostic << "Is topic creator: #{topic&.user_id == user&.id}"
        user_has_posted = Post.exists?(topic_id: topic&.id, user_id: user&.id)
        diagnostic << "User has posted: #{user_has_posted}"
        diagnostic << "Target has posted: #{Post.exists?(topic_id: topic&.id, user_id: feedback_to_user&.id)}"

        Rails.logger.error "PERMISSION DENIED: #{diagnostic.join(' | ')}"

        # Provide specific error message based on the failure reason
        custom_message = if !user_has_posted
          'user_feedbacks.errors.must_have_posted_in_topic'
        else
          'user_feedbacks.errors.cannot_create_feedback'
        end

        raise Discourse::InvalidAccess.new(
          "not permitted to create feedback",
          nil,
          custom_message: custom_message
        )
      end
    end

    private

    def is_my_own_feedback?(feedback)
      user && feedback.user_id == user.id
    end
  end
end
