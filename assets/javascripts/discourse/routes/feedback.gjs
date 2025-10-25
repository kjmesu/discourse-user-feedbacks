import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class FeedbackRoute extends DiscourseRoute {
  async model(params) {
    return await ajax(`/user_feedbacks/${params.id}.json`);
  }
}
