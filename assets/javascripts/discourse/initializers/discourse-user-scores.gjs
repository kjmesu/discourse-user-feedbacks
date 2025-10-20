import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import RatingInput from "../components/rating-input";

function initializeDiscourseUserFeedbacks(api) {
  const siteSettings = api.container.lookup("site-settings:main");

  api.addTrackedPostProperties("user_average_rating", "user_rating_count");

  if (siteSettings.user_feedbacks_display_average_ratings_beside_username_on_post) {
    api.renderAfterWrapperOutlet(
      "post-meta-data-poster-name",
      class extends Component {
        static shouldRender(args) {
          return !!args?.outletArgs?.post?.user_id;
        }

        get _post() {
          return this.args?.outletArgs?.post;
        }

        get avgRating() {
          return Number(this._post?.user_average_rating ?? 0);
        }

        get ratingCount() {
          return Number(this._post?.user_rating_count ?? 0);
        }

        get feedbacksUrl() {
          return `${this._post?.usernameUrl}/feedbacks`;
        }

        <template>
          <div class="average-ratings">
            <RatingInput @readOnly={{true}} @value={{this.avgRating}} />
            <span class="rating-count">
              <a href={{this.feedbacksUrl}}>
                {{this.ratingCount}} Trades
              </a>
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
