import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import RatingInput from "../components/rating-input";

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
        static shouldRender(args) {
          return args.post.user_id > 0;
        }  

        <template>
          <div class="average-ratings">
            <RatingInput
              @readOnly={{true}}
              @value={{(or @outletArgs.post.user_average_rating 0)}}
            />
            <span class="rating-count">
              <a href="{{@outletArgs.post.usernameUrl}}/feedbacks">{{@outletArgs.post.user_rating_count}} Trades</a>
            </span>
          </div>
        </template>
      }
    );
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
