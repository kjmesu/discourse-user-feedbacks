import { withPluginApi } from "discourse/lib/plugin-api";
import PostUserRating from "../components/post-user-rating";

function initializeDiscourseUserFeedbacks(api) {
  const siteSettings = api.container.lookup("site-settings:main");

  api.addTrackedPostProperties("user_average_rating", "user_rating_count");

  if (siteSettings.user_feedbacks_display_average_ratings_beside_username_on_post) {
    api.renderAfterWrapperOutlet("post-meta-data-poster-name", PostUserRating);
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
