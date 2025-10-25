import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

export default class UserFeedbacksController extends Controller {
  @service currentUser;

  @tracked rating = 0;
  @tracked review = "";
  @tracked readOnly = false;
  @tracked feedback_to_id = null;

  get placeholder() {
    return i18n("discourse_user_feedbacks.user_feedbacks.user_review.placeholder");
  }

  get canGiveFeedback() {
    return this.feedback_to_id !== this.currentUser && this.currentUser?.id;
  }

  get disabled() {
    return !(parseInt(this.rating) > 0);
  }

  @action
  createFeedback() {
    this.readOnly = true;
    ajax("/user_feedbacks", {
      type: "POST",
      data: {
        rating: parseInt(this.rating),
        review: this.review,
        feedback_to_id: this.feedback_to_id,
      },
    }).then((response) => {
      this.model.feedbacks.unshiftObject(response.user_feedback);
      this.rating = 0;
      this.review = "";
    });
  }

  @action
  handleFeedbackDeleted(id) {
    const remaining = this.model.feedbacks.filter((f) => f.id !== id);
    this.model.feedbacks = remaining;
  }
}
