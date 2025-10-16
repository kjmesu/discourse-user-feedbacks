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
  
        get checkedOne() {
          return this.args.post.user_average_rating >= 1;
        }
        get checkedTwo() {
          return this.args.post.user_average_rating >= 2;
        }
        get checkedThree() {
          return this.args.post.user_average_rating >= 3;
        }
        get checkedFour() {
          return this.args.post.user_average_rating >= 4;
        }
        get checkedFive() {
          return this.args.post.user_average_rating >= 5;
        }
  
        get percentageOne() {
          return this.args.post.user_average_rating > 0 && this.args.post.user_average_rating < 1 ? ((Math.round(this.args.post.user_average_rating * 100) / 100) % 1) * 100 : 0;
        }
        get percentageTwo() {
          return this.args.post.user_average_rating > 1 && this.args.post.user_average_rating < 2 ? ((Math.round(this.args.post.user_average_rating * 100) / 100) % 1) * 100 : 0;
        }
        get percentageThree() {
          return this.args.post.user_average_rating > 2 && this.args.post.user_average_rating < 3 ? ((Math.round(this.args.post.user_average_rating * 100) / 100) % 1) * 100 : 0;
        }
        get percentageFour() {
          return this.args.post.user_average_rating > 3 && this.args.post.user_average_rating < 4 ? ((Math.round(this.args.post.user_average_rating * 100) / 100) % 1) * 100 : 0;
        }
        get percentageFive() {
          return this.args.post.user_average_rating > 4 && this.args.post.user_average_rating < 5 ? ((Math.round(this.args.post.user_average_rating * 100) / 100) % 1) * 100 : 0;
        }
      },
      <template>
        <div class="average-ratings">
          <RatingInput
            @readOnly={{true}}
            @checkedOne={{@outletArgs.post.user_average_rating >= 1}}
            @checkedTwo={{@outletArgs.post.user_average_rating >= 2}}
            @checkedThree={{@outletArgs.post.user_average_rating >= 3}}
            @checkedFour={{@outletArgs.post.user_average_rating >= 4}}
            @checkedFive={{@outletArgs.post.user_average_rating >= 5}}
            @percentageOne={{if (and (gt @outletArgs.post.user_average_rating 0) (lt @outletArgs.post.user_average_rating 1)) (mul (mod (div (round (mul @outletArgs.post.user_average_rating 100)) 100) 1) 100) 0}}
            @percentageTwo={{if (and (gt @outletArgs.post.user_average_rating 1) (lt @outletArgs.post.user_average_rating 2)) (mul (mod (div (round (mul @outletArgs.post.user_average_rating 100)) 100) 1) 100) 0}}
            @percentageThree={{if (and (gt @outletArgs.post.user_average_rating 2) (lt @outletArgs.post.user_average_rating 3)) (mul (mod (div (round (mul @outletArgs.post.user_average_rating 100)) 100) 1) 100) 0}}
            @percentageFour={{if (and (gt @outletArgs.post.user_average_rating 3) (lt @outletArgs.post.user_average_rating 4)) (mul (mod (div (round (mul @outletArgs.post.user_average_rating 100)) 100) 1) 100) 0}}
            @percentageFive={{if (and (gt @outletArgs.post.user_average_rating 4) (lt @outletArgs.post.user_average_rating 5)) (mul (mod (div (round (mul @outletArgs.post.user_average_rating 100)) 100) 1) 100) 0}}
          />
          <span class="rating-count">
            <a href="{{@outletArgs.post.usernameUrl}}/feedbacks">{{@outletArgs.post.user_rating_count}} Trades</a>
          </span>
        </div>
      </template>
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
