import Component from "@ember/component";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default Component.extend({
  currentUser: null,

  @action
  deleteFeedback(id) {
    if (!confirm("Are you sure you want to delete this feedback?")) return;

    ajax(`/user_feedbacks/${id}`, {
      type: "DELETE",
    }).then(() => {
      this.onDelete?.(id);
    });
  },
});
