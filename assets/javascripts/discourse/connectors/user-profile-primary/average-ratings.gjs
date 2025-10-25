import Component from "@glimmer/component";
import { service } from "@ember/service";
import RatingInput from "../../components/rating-input";
import { i18n } from "discourse-i18n";

export default class AverageRatings extends Component {
  @service siteSettings;

  get shouldRender() {
    if (!this.args.outletArgs?.model?.id || this.args.outletArgs.model.id <= 0) {
      return false;
    }

    if (!this.siteSettings.user_feedbacks_display_average_ratings_on_profile) {
      return false;
    }

    return true;
  }

  <template>
    {{#if this.shouldRender}}
      <div class="average-ratings">
        <RatingInput @value={{@outletArgs.model.average_rating}} @readOnly={{true}} />
        <span class="rating-count">
          <a href="{{@outletArgs.model.path}}/feedbacks">
            {{i18n "discourse_user_feedbacks.user_feedbacks.user_ratings_count" count=@outletArgs.model.rating_count}}
          </a>
        </span>
      </div>
    {{/if}}
  </template>
}
