# frozen_string_literal: true
# name: discourse-user-feedbacks
# about: Allow users to give feedback and track legacy trade counts
# version: 1.0.0
# authors: Ahmed Gagan
# url: https://github.com/Ahmedgagan/discourse-user-feedbacks

enabled_site_setting :user_feedbacks_enabled

if respond_to?(:register_svg_icon)
  register_svg_icon "fas fa-star"
end

register_asset "stylesheets/user-feedbacks.scss"

after_initialize do
  module ::DiscourseUserFeedbacks
    PLUGIN_NAME ||= "discourse-user-feedbacks"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseUserFeedbacks
    end
  end

  # =========================================================
  # Load plugin files
  # =========================================================
  [
    "../app/controllers/user_feedbacks_controller.rb",
    "../app/serializers/user_feedback_serializer.rb",
    "../app/models/user_feedback.rb",
    "../lib/discourse_user_feedbacks/user_extension.rb",
    "../lib/discourse_user_feedbacks/user_feedbacks_constraint.rb",
    "../config/routes"
  ].each { |path| require File.expand_path(path, __FILE__) }

  # =========================================================
  # Routing
  # =========================================================
  Discourse::Application.routes.append do
    %w{users u}.each do |root_path|
      get "#{root_path}/:username/feedbacks" => "users#preferences", constraints: { username: RouteFormat.username }
    end

    get "/feedbacks/*path" => "list#latest"

    put "/legacy_trades/:id" => "legacy_trades#update"

    mount ::DiscourseUserFeedbacks::Engine, at: "/"
  end

  # =========================================================
  # Patch User model
  # =========================================================
  reloadable_patch do |plugin|
    User.class_eval { prepend DiscourseUserFeedbacks::UserExtension }
  end

  # =========================================================
  # Feedback Serializer Extensions
  # =========================================================
  add_to_serializer(:basic_user, :feedbacks_to) do
    user = object.is_a?(User) ? object : object[:user]
    return nil unless user && user.feedbacks
    user.feedbacks.pluck(:feedback_to_id)
  end

  add_to_serializer(:basic_user, :average_rating) do
    user = object.is_a?(User) ? object : object[:user]
    return nil unless user

    count = DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).count
    count = 1 if count <= 0
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).sum(:rating) / count.to_f
  end

  add_to_serializer(:basic_user, :rating_count) do
    user = object.is_a?(User) ? object : object[:user]
    return nil unless user
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).count
  end

  add_to_serializer(:post, :user_average_rating) do
    user = object.user
    count = DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).count
    count = 1 if count <= 0
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: user.id).sum(:rating) / count.to_f
  end

  add_to_serializer(:post, :user_rating_count) do
    DiscourseUserFeedbacks::UserFeedback.where(feedback_to_id: object.user.id).count
  end

  # =========================================================
  # Legacy Trade Count: User Custom Field
  # =========================================================
  add_to_serializer(:user, :legacy_trade_count, false) do
    object.custom_fields["user_feedbacks_legacy_trade_count"].to_i
  end

  register_editable_user_custom_field :user_feedbacks_legacy_trade_count
  
  add_to_class(:user, :legacy_trade_count) do
    self.custom_fields["user_feedbacks_legacy_trade_count"].to_i
  end

  add_to_serializer(:admin_user, :legacy_trade_count) do
    object.custom_fields["user_feedbacks_legacy_trade_count"].to_i
  end

  User.register_custom_field_type("user_feedbacks_legacy_trade_count", :integer)
  DiscoursePluginRegistry.serialized_current_user_fields << "user_feedbacks_legacy_trade_count"

  # =========================================================
  # Guardian extensions (moderation permissions)
  # =========================================================
  Guardian.class_eval do
    def can_delete_feedback?
      user&.staff?
    end

    def ensure_can_delete_feedback!
      raise Discourse::InvalidAccess.new unless can_delete_feedback?
    end
  end
end
