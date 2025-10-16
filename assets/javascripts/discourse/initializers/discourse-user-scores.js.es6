import { withPluginApi } from "discourse/lib/plugin-api";
import ComponentConnector from "discourse/widgets/component-connector";
import I18n from "I18n";

function initializeDiscourseUserFeedbacks(api) {
  const site = api.container.lookup("site:main");
  const siteSettings = api.container.lookup("site-settings:main");

  api.addTrackedPostProperties("user_average_rating", "user_rating_count");

  if (siteSettings.user_feedbacks_display_average_ratings_beside_username_on_post) {
    api.renderAfterWrapperOutlet("post-username", (attrs) => {
      const value = attrs.user_average_rating;
      if (attrs.user_id <= 0) return;
      if (site.mobileView) return;

      return [
        h("div.average-ratings", [
          new ComponentConnector(
            null,
            "rating-input",
            {
              layoutName: "components/rating-input",
              readOnly: true,
              checkedOne: value >= 1,
              checkedTwo: value >= 2,
              checkedThree: value >= 3,
              checkedFour: value >= 4,
              checkedFive: value >= 5,
              percentageOne:
                value > 0 && value < 1 ? ((Math.round(value * 100) / 100) % 1) * 100 : 0,
              percentageTwo:
                value > 1 && value < 2 ? ((Math.round(value * 100) / 100) % 1) * 100 : 0,
              percentageThree:
                value > 2 && value < 3 ? ((Math.round(value * 100) / 100) % 1) * 100 : 0,
              percentageFour:
                value > 3 && value < 4 ? ((Math.round(value * 100) / 100) % 1) * 100 : 0,
              percentageFive:
                value > 4 && value < 5 ? ((Math.round(value * 100) / 100) % 1) * 100 : 0,
            },
            ["value"]
          ),
          h(
            "span.rating-count",
            h(
              "a",
              { href: `${attrs.usernameUrl}/feedbacks` },
              I18n.t("discourse_user_feedbacks.user_feedbacks.user_ratings_count", {
                count: attrs.user_rating_count,
              })
            )
          ),
        ]),
      ];
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
