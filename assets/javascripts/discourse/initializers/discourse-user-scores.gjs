import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";

function initializeDiscourseUserFeedbacks(api) {
  const site = api.container.lookup("site:main");
  const siteSettings = api.container.lookup("site-settings:main");

  api.addTrackedPostProperties("user_average_rating", "user_rating_count");

  if (
    siteSettings.user_feedbacks_display_average_ratings_beside_username_on_post
  ) {
    api.renderAfterWrapperOutlet(
    "post-meta-data-poster-name",
    class extends Component {
      static shouldRender({ post }) {
        return post.user_id > 0;
      }

      <template>
        <span class="average-ratings">
          <RatingInput @value={{@post.user_average_rating}} @readOnly={{true}} />
          <span class="rating-count">
            <a href="{{@post.username_url}}/feedbacks>{{@post.user_rating_count}}</a>
          </span>
        </template>
    });
  }
}

export default {
  name: "discourse-user-feedbacks",

  initialize(container) {
    const siteSettings = container.lookup("site-settings:main");

    if (siteSettings.user_feedbacks_enabled) {
      withPluginApi("0.10.1", initializeDiscourseUserFeedbacks);
    }
  },
};
