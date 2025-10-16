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
      static shouldRender({ post }) {
        return post.user_id > 0;
      }

      const checkedOne = post.user_average_rating >= 1;
      const checkedTwo = post.user_average_rating >= 2;
      const checkedThree = post.user_average_rating >= 3;
      const checkedFour = post.user_average_rating >= 4;
      const checkedFive = post.user_average_rating >= 5;

      const percentageOne = post.user_average_rating > 0 && post.user_average_rating < 1 ? ((Math.round(post.user_average_rating * 100) / 100) % 1) * 100 : 0;
      const percentageTwo = post.user_average_rating > 1 && post.user_average_rating < 2 ? ((Math.round(post.user_average_rating * 100) / 100) % 1) * 100 : 0;
      const percentageThree = post.user_average_rating > 2 && post.user_average_rating < 3 ? ((Math.round(post.user_average_rating * 100) / 100) % 1) * 100 : 0;
      const percentageFour = post.user_average_rating > 3 && post.user_average_rating < 4 ? ((Math.round(post.user_average_rating * 100) / 100) % 1) * 100 : 0;
      const percentageFive = post.user_average_rating > 4 && post.user_average_rating < 5 ? ((Math.round(post.user_average_rating * 100) / 100) % 1) * 100 : 0;

      <template>
        <div class="average-ratings">
          <RatingInput
            @readOnly={{true}}
            @checkedOne={{@checkedOne}}
            @checkedTwo={{@checkedTwo}}
            @checkedThree={{@checkedThree}}
            @checkedFour={{@checkedFour}}
            @checkedFive={{@checkedFive}}
            @percentageOne={{@percentageOne}}
            @percentageTwo={{@percentageTwo}}
            @percentageThree={{@percentageThree}}
            @percentageFour={{@percentageFour}}
            @percentageFive={{@percentageFive}}
          />

          <span class="rating-count">
            <a href="{{@post.usernameUrl}}/feedbacks">{{@post.user_rating_count}} Trades</a>
          </span>
        </div>
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
