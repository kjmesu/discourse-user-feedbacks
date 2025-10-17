import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default Component.extend({
  router: service(),

  @action
  copyPermalink(id, event) {
    event.preventDefault();
    const url = `${window.location.origin}${this.router.urlFor("feedback", id)}`;
    navigator.clipboard.writeText(url);
    this.appEvents?.trigger("composer:show-notification", {
      message: I18n.t("discourse_user_feedbacks.user_feedbacks.link_copied"),
      type: "success",
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
