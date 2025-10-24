# frozen_string_literal: true

DiscourseUserFeedbacks::Engine.routes.draw do
  resources :user_feedbacks, constraints: DiscourseUserFeedbacks::UserFeedbacksConstraint.new do
    member do
      get :show
      post :flag
      put :recover
      put :unhide
      post :notice
    end
  end
end
