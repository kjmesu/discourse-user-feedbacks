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

    count = DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).count
    count = 1 if count <= 0
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).sum(:rating) / count.to_f
    return 0.0 if count == 0
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).average(:rating).to_f
  end

  add_to_serializer(:basic_user, :rating_count) do
    user = object
    user = object[:user] if object.class != User

    return nil if !user

    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).count
  end

  add_to_serializer(:post, :user_average_rating) do
    user = object.user
    count = DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).count
    count = 1 if count <= 0

    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).sum(:rating) / count.to_f
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: object.user_id).average(:rating).to_f
  end

  add_to_serializer(:post, :user_rating_count) do
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: object.user.id).count
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
  end
end
