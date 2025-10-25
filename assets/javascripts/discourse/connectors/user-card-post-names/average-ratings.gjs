import Component from "@glimmer/component";
import { service } from "@ember/service";
import RatingInput from "../../components/rating-input";
import { i18n } from "discourse-i18n";

export default class AverageRatings extends Component {
  @service siteSettings;

  get shouldRender() {
    if (!this.args.outletArgs?.user?.id || this.args.outletArgs.user.id <= 0) {
      return false;
    }

    if (!this.siteSettings.user_feedbacks_display_average_ratings_on_user_card) {
      return false;
    }

    return true;
  }

  <template>
    {{#if this.shouldRender}}
      <div class="average-ratings">
        <RatingInput @value={{@outletArgs.user.average_rating}} @readOnly={{true}} />
        <span class="rating-count">
          <a href="{{@outletArgs.user.path}}/feedbacks">
            {{i18n "discourse_user_feedbacks.user_feedbacks.user_ratings_count" count=@outletArgs.user.rating_count}}
          </a>
        </span>
      </div>
    {{/if}}
  </template>
}
