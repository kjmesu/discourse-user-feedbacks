import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import ModalFunctionality from "discourse/mixins/modal-functionality";

export default Controller.extend(ModalFunctionality, {
  rating: null,
  review: null,
  post: null,
  topic: null,
  feedbackToUserId: null,
  feedbackToUsername: null,

  onShow() {
    this.setProperties({
      rating: null,
      review: null
    });
  },

  @action
  submitFeedback() {
    if (!this.rating || this.rating <= 0) {
      this.flash(I18n.t("discourse_user_feedbacks.user_feedbacks.errors.rating_required"), "error");
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
        this.send("closeModal");

        // Refresh the topic to update any UI
        if (this.topic) {
          this.topic.reload();
        }

        // Show success message
        this.appEvents.trigger("modal-body:flash", {
          text: I18n.t("discourse_user_feedbacks.user_feedbacks.feedback_submitted"),
          messageClass: "success"
        });
      })
      .catch(popupAjaxError);
  },

  @action
  updateRating(value) {
    this.set("rating", value);
  },

  @action
  cancel() {
    this.send("closeModal");
  }
});
