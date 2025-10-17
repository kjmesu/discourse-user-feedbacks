import Component from "@ember/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";
import { later } from "@ember/runloop";

export default Component.extend({
  router: service(),

  didReceiveAttrs() {
    this._super(...arguments);

    const createdAt = this.get("feedback.created_at");
    this.set("createdAtDate", createdAt ? new Date(createdAt) : null);
  },

  @action
  deleteFeedback(id) {
    if (!confirm(I18n.t("discourse_user_feedbacks.user_feedbacks.delete_confirm"))) {
      return;
    }

    ajax(`/user_feedbacks/${id}`, {
      type: "DELETE",
    }).then(() => {
      this.onDelete?.(id);
    });
  },

  @action
  async copyPermalink(id, event) {
    event.preventDefault();

    const element = event.currentTarget;
    const wrapper = element.closest(".permalink-button-wrapper");
    const message = wrapper.querySelector(".permalink-message");
    const check = element.querySelector(".permalink-check");
    const url = `${window.location.origin}${this.router.urlFor("feedback", id)}`;

    try {
      await navigator.clipboard.writeText(url);
    } catch {
      const tempInput = document.createElement("input");
      tempInput.style.position = "absolute";
      tempInput.style.left = "-9999px";
      tempInput.value = url;
      document.body.appendChild(tempInput);
      tempInput.select();
      document.execCommand("copy");
      document.body.removeChild(tempInput);
    }

    check.classList.add("visible");
    element.classList.add("link-copied");
    message.classList.add("visible");

    later(() => {
      check.classList.remove("visible");
      element.classList.remove("link-copied");
      message.classList.remove("visible");
    }, 2000);
  },
});
