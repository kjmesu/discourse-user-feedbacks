# frozen_string_literal: true

DiscourseUserFeedbacks::Engine.routes.draw do
  resources :user_feedbacks, constraints: DiscourseUserFeedbacks::UserFeedbacksConstraint.new do
    member do
      get :show_permalink
    end
  end
end
