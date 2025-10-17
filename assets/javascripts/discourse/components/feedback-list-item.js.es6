import Component from "@ember/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import Clipboard from "discourse/lib/clipboard";
import I18n from "I18n";
import { later } from "@ember/runloop";

export default Component.extend({
  router: service(),

  @action
  deleteFeedback(id) {
    if (!confirm(I18n.t("user_feedbacks.delete_confirm"))) return;

    ajax(`/user_feedbacks/${id}`, {
      type: "DELETE",
    }).then(() => {
      this.onDelete?.(id);
    });
  },

  @action
  copyPermalink(id, event) {
    event.preventDefault();

    const element = event.currentTarget;
    const url = `${window.location.origin}${this.router.urlFor("feedback", id)}`;

    Clipboard.copy(url, element);

    const originalTitle = element.getAttribute("title");
    element.setAttribute("title", I18n.t("post.share.link_copied"));
    element.classList.add("link-copied");

    later(() => {
      element.setAttribute("title", originalTitle);
      element.classList.remove("link-copied");
    }, 2000);
  },
});
