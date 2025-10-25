import DiscourseRoute from "discourse/routes/discourse";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";

export default class UserFeedbacksRoute extends DiscourseRoute {
  @service currentUser;

  async model() {
    const user = this.modelFor("user");
    const response = await ajax("/user_feedbacks.json", {
      type: "GET",
      data: {
        feedback_to_id: user.get("id"),
      },
    });
    return response;
  }

  setupController(controller, model) {
    const user = this.modelFor("user");
    controller.setProperties({
      feedback_to_id: user.get("id"),
      readOnly: this.currentUser && this.currentUser.id === user.get("id"),
      model: model,
    });
  }
}
