import Component from "@glimmer/component";
import { withPluginApi } from "discourse/lib/plugin-api";
import PostUserRating from "../components/post-user-rating";

function initializeDiscourseUserFeedbacks(api) {
  const siteSettings = api.container.lookup("site-settings:main");

  api.addTrackedPostProperties("user_average_rating", "user_rating_count", "legacy_trade_count");

  if (siteSettings.user_feedbacks_display_average_ratings_beside_username_on_post) {
    api.renderAfterWrapperOutlet(
      "post-meta-data-poster-name",
      class extends Component {
        static shouldRender({ post }) {
          return !!post?.user_id;
        }

        get post() {
          return this.args.post;
        }

        get totalTrades() {
          const legacy = Number(this.post?.legacy_trade_count ?? 0);
          const ratings = Number(this.post?.user_rating_count ?? 0);
          return legacy + ratings;
        }

        <template>
          <div class="average-ratings">
            <PostUserRating @post={{this.post}} />
            <span class="rating-count">
              <a href="{{this.post.usernameUrl}}/feedbacks">
                {{this.totalTrades}} Trades
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
