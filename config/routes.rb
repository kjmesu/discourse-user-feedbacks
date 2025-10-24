# frozen_string_literal: true

DiscourseUserFeedbacks::Engine.routes.draw do
  get 'user_feedbacks' => 'user_feedbacks#index', constraints: DiscourseUserFeedbacks::UserFeedbacksConstraint.new

  resources :user_feedbacks, except: [:index] do
    member do
      get :show
      post :flag
      put :recover
      put :unhide
      put :notice
    end
  end
end
