# frozen_string_literal: true

DiscourseUserFeedbacks::Engine.routes.draw do
  put 'user_feedbacks/:id/notice' => 'user_feedbacks#notice', constraints: DiscourseUserFeedbacks::UserFeedbacksConstraint.new

  resources :user_feedbacks, constraints: DiscourseUserFeedbacks::UserFeedbacksConstraint.new do
    member do
      get :show
      post :flag
      put :recover
      put :unhide
    end
  end
end
