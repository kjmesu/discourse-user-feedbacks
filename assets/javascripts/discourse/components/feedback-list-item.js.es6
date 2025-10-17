import Component from "@ember/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import showShareLink from "discourse/lib/show-share-link";

export default Component.extend({
  router: service(),

  @action
  triggerShare(id, event) {
    event.preventDefault();

    const url = `${window.location.origin}${this.router.urlFor("feedback", id)}`;

    dispatch("post:share", {
      postId: null,
      url,
      element: event.currentTarget
    });
  },

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
