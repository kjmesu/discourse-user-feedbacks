import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";
import discourseComputed from "discourse-common/utils/decorators";

export default Controller.extend({
  rating: 0,
  review: "",
  readOnly: false,
  placeholder: I18n.t(
    "discourse_user_feedbacks.user_feedbacks.user_review.placeholder"
  ),

  @discourseComputed("feedback_to_id")
  canGiveFeedback(feedback_to_id) {
    return feedback_to_id !== this.currentUser && this.currentUser.id;
  },

  @discourseComputed("rating")
  disabled(rating) {
    return !(parseInt(rating) > 0);
  },

  createFeedback: action(function() {
    this.set("readOnly", true);
    ajax("/user_feedbacks", {
      type: "POST",
      data: {
        rating: parseInt(this.rating),
        review: this.review,
        feedback_to_id: this.feedback_to_id,
      },
    }).then((response) => {
      this.model.feedbacks.unshiftObject(response.user_feedback);
      this.set("rating", 0);
      this.set("review", "");
    });
  }),

  @action
  handleFeedbackDeleted(id) {
    const remaining = this.model.feedbacks.filter((f) => f.id !== id);
    this.set("model.feedbacks", remaining);
  },
});
