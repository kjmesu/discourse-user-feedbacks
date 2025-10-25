import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import i18n from "discourse-common/helpers/i18n";
import RatingInput from "discourse/plugins/discourse-user-feedbacks/discourse/components/rating-input";
import I18n from "I18n";

export default class CreateFeedbackModal extends Component {
  @service modal;
  @service siteSettings;
  @service toasts;
  @tracked rating = null;
  @tracked review = "";

  get post() {
    return this.args.model?.post;
  }

  get topic() {
    return this.args.model?.topic;
  }

  get feedbackToUserId() {
    return this.args.model?.feedbackToUserId;
  }

  get feedbackToUsername() {
    return this.args.model?.feedbackToUsername;
  }

  @action
  updateRating(value) {
    this.rating = value;
  }

  @action
  updateReview(event) {
    this.review = event.target.value;
  }

  @action
  submitFeedback() {
    if (!this.rating || this.rating <= 0) {
      alert(I18n.t("discourse_user_feedbacks.user_feedbacks.errors.rating_required") || "Please select a rating");
      return;
    }

    const data = {
      rating: this.rating,
      feedback_to_id: this.feedbackToUserId,
      topic_id: this.topic.id,
      post_id: this.post.id
    };

    if (this.review && this.review.trim().length > 0) {
      data.review = this.review;
    }

    ajax("/user_feedbacks", {
      type: "POST",
      data: data
    })
      .then(() => {
        this.modal.close();

        // Show success toast notification
        this.toasts.success({
          duration: 3000,
          data: { message: I18n.t("discourse_user_feedbacks.feedback_submitted") }
        });
      })
      .catch(popupAjaxError);
  }

  @action
  cancel() {
    this.modal.close();
  }

  <template>
    <DModal
      @title={{i18n "discourse_user_feedbacks.create_feedback_modal.title" username=this.feedbackToUsername}}
      @closeModal={{this.cancel}}
      class="create-feedback-modal"
    >
      <:body>
        <div class="feedback-form">
          <div class="feedback-rating">
            <label>{{i18n "discourse_user_feedbacks.user_feedbacks.add_rating"}}</label>
            <RatingInput @value={{this.rating}} @onChange={{this.updateRating}} />
          </div>

          <div class="feedback-review">
            <label>{{i18n "discourse_user_feedbacks.user_feedbacks.user_review.placeholder"}}</label>
            <textarea
              class="review-textarea"
              value={{this.review}}
              placeholder={{i18n "discourse_user_feedbacks.user_feedbacks.user_review.placeholder"}}
              {{on "input" this.updateReview}}
            ></textarea>
          </div>
        </div>
      </:body>

      <:footer>
        <DButton
          @action={{this.submitFeedback}}
          @label="discourse_user_feedbacks.create_feedback_modal.submit"
          class="btn-primary"
        />
        <DButton
          @action={{this.cancel}}
          @label="discourse_user_feedbacks.create_feedback_modal.cancel"
          class="btn-default"
        />
      </:footer>
    </DModal>
  </template>
}
