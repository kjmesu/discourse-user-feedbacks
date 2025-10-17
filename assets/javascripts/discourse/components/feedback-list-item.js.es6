import Component from "@ember/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";
import { later } from "@ember/runloop";

export default Component.extend({
  router: service(),

  @action
  deleteFeedback(id) {
    if (!confirm(I18n.t("discourse_user_feedbacks.user_feedbacks.delete_confirm"))) return;

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
    const url = `${window.location.origin}${this.router.urlFor("feedback", id)}`;
  
    try {
      await navigator.clipboard.writeText(url);
    } catch (e) {
      const tempInput = document.createElement("input");
      tempInput.style.position = "absolute";
      tempInput.style.left = "-9999px";
      tempInput.value = url;
      document.body.appendChild(tempInput);
      tempInput.select();
      document.execCommand("copy");
      document.body.removeChild(tempInput);
    }
  
    const icon = element.querySelector("svg use");
    const originalIcon = icon.getAttribute("href");
    icon.setAttribute("href", "#check");
  
    const originalTitle = element.getAttribute("title");
    element.setAttribute("title", I18n.t("post.share.link_copied"));
    element.classList.add("link-copied");
  
    later(() => {
      icon.setAttribute("href", originalIcon);

      element.setAttribute("title", originalTitle);
      element.classList.remove("link-copied");
    }, 2000);
  }
});
