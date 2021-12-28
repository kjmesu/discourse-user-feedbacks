# frozen_string_literal: true
# name: discourse-user-scores
# about: add user scores calculated from DirectoryItem stats
# version: 1.0.0
# authors: @orlando
# url: https://github.com/orlando/discourse-user-scores

enabled_site_setting :user_scores_enabled

if respond_to?(:register_svg_icon)
  register_svg_icon "fas fa-star"
end

register_asset 'stylesheets/user-feedbacks.scss'

after_initialize do
  module ::DiscourseUserScores
    PLUGIN_NAME ||= 'discourse-user-scores'

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseUserScores
    end
  end

  Discourse::Application.routes.append do
    %w{users u}.each do |root_path|
      get "#{root_path}/:username/feedbacks" => "users#preferences", constraints: { username: RouteFormat.username }
    end
    mount ::DiscourseUserScores::Engine, at: '/'
  end

  [
    "../app/controllers/user_feedbacks_controller.rb",
    "../app/serializers/user_feedback_serializer.rb",
    "../app/models/user_feedback.rb",
    "../config/routes",
    "../lib/discourse_user_scores/user_extension.rb"
  ].each { |path| require File.expand_path(path, __FILE__) }

  reloadable_patch do |plugin|
    User.class_eval { prepend DiscourseRewards::UserExtension }
  end

  # Monkey patch ActiveModel::Serializer to allow us
  # reload child serializers attributes after parent is modified
  class ::ActiveModel::Serializer
    def self.reload
      self._attributes = _attributes.merge(superclass._attributes)
    end
  end

  add_to_serializer(:basic_user, :feedbacks_to) do
    user = object
    user = object[:user] if object.class != User

    user.feedbacks.pluck(:feedback_to_id)
  end

  add_to_serializer(:basic_user, :average_rating) do
    user = object
    user = object[:user] if object.class != User

    count = DiscourseUserScores::UserFeedback.where(feedback_to_id: user.id).count
    count = 1 if count <= 0
    DiscourseUserScores::UserFeedback.where(feedback_to_id: user.id).sum(:rating) / count.to_f
  end

  add_to_serializer(:basic_user, :rating_count) do
    user = object
    user = object[:user] if object.class != User

    DiscourseUserScores::UserFeedback.where(feedback_to_id: user.id).count
  end

  add_to_serializer(:post, :user_average_rating) do
    user = object.user
    count = DiscourseUserScores::UserFeedback.where(feedback_to_id: user.id).count
    count = 1 if count <= 0

    DiscourseUserScores::UserFeedback.where(feedback_to_id: user.id).sum(:rating) / count.to_f
  end

  add_to_serializer(:post, :user_rating_count) do
    DiscourseUserScores::UserFeedback.where(feedback_to_id: object.user.id).count
  end

  add_to_serializer(:basic_user, :score) do
    # Cache the score for 1 day since doing
    # this for every user is expensive
    cache_key = "DirectoryItem-user-#{user.id}"
    stats = Rails.cache.fetch("#{cache_key}/all", expires_in: 1.day) do
      DirectoryItem.where(user_id: user.id, period_type: 1).first
    end

    return 0 if stats.nil?

    like_received_points = stats.likes_received * SiteSetting.user_scores_like_received_points
    like_given_points = stats.likes_given * SiteSetting.user_scores_like_given_points
    topic_points = stats.topic_count * SiteSetting.user_scores_topic_points
    topic_entered_points = stats.topics_entered * SiteSetting.user_scores_topic_entered_points
    post_points = stats.post_count * SiteSetting.user_scores_post_points
    post_read_points = stats.posts_read * SiteSetting.user_scores_post_read_points
    day_visited_points = stats.days_visited * SiteSetting.user_scores_day_visited_points

    [
      like_received_points,
      like_given_points,
      topic_points,
      topic_entered_points,
      post_points,
      post_read_points,
      day_visited_points
    ].sum
  end

  BasicUserSerializer.descendants.each(&:reload)
end
