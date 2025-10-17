import Component from "@ember/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { sharedBehaviorOnClick } from "discourse/components/post/menu/button-wrapper";

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
  copyPermalink(id, event) {
    event.preventDefault();

    const element = event.currentTarget;
    const url = `${window.location.origin}${this.router.urlFor("feedback", id)}`;

    sharedBehaviorOnClick({
      id: id,
      element,
      type: "share",
      shareUrl: url,
    });
  },
});
