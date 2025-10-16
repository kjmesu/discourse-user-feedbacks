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

        get checkedOne() {
          return this.args.outletArgs.post.user_average_rating >= 1;
        }
        get checkedTwo() {
          return this.args.outletArgs.post.user_average_rating >= 2;
        }
        get checkedThree() {
          return this.args.outletArgs.post.user_average_rating >= 3;
        }
        get checkedFour() {
          return this.args.outletArgs.post.user_average_rating >= 4;
        }
        get checkedFive() {
          return this.args.outletArgs.post.user_average_rating >= 5;
        }
        get percentageOne() {
          const rating = this.args.outletArgs.post.user_average_rating;
          if (rating > 0 && rating < 1) {
            return ((Math.round(rating * 100) / 100) % 1) * 100;
          }
          return 0;
        }
        get percentageTwo() {
          const rating = this.args.outletArgs.post.user_average_rating;
          if (rating > 1 && rating < 2) {
            return ((Math.round(rating * 100) / 100) % 1) * 100;
          }
          return 0;
        }
        get percentageThree() {
          const rating = this.args.outletArgs.post.user_average_rating;
          if (rating > 2 && rating < 3) {
            return ((Math.round(rating * 100) / 100) % 1) * 100;
          }
          return 0;
        }
        get percentageFour() {
          const rating = this.args.outletArgs.post.user_average_rating;
          if (rating > 3 && rating < 4) {
            return ((Math.round(rating * 100) / 100) % 1) * 100;
          }
          return 0;
        }
        get percentageFive() {
          const rating = this.args.outletArgs.post.user_average_rating;
          if (rating > 4 && rating < 5) {
            return ((Math.round(rating * 100) / 100) % 1) * 100;
          }
          return 0;
        }        

        <template>
          <div class="average-ratings">
            <RatingInput
              @readOnly={{true}}
              @checkedOne={{this.checkedOne}}
              @checkedTwo={{this.checkedTwo}}
              @checkedThree={{this.checkedThree}}
              @checkedFour={{this.checkedFour}}
              @checkedFive={{this.checkedFive}}
              @percentageOne={{this.percentageOne}}
              @percentageTwo={{this.percentageTwo}}
              @percentageThree={{this.percentageThree}}
              @percentageFour={{this.percentageFour}}
              @percentageFive={{this.percentageFive}}
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
