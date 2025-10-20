import Component from "@glimmer/component";
import { service } from "@ember/service";
import i18n from "discourse-common/helpers/i18n";
import RatingInput from "discourse/plugins/discourse-user-feedbacks/discourse/components/rating-input";

export default class AverageRatingsCard extends Component {
  @service siteSettings;

  get user() {
    return this.args?.outletArgs?.user;
  }

  get shouldRender() {
    const user = this.user;
    if (!user || user.id <= 0) {
      return false;
    }
    return this.siteSettings.user_feedbacks_display_average_ratings_on_user_card;
  }

  get totalCount() {
    const base = Number(this.user?.rating_count || 0);
    const legacy = Number(this.user?.legacy_trade_count || 0);
    return base + legacy;
  }

  <template>
    {{#if this.shouldRender}}
      <div class="average-ratings">
        <RatingInput @value={{this.user.average_rating}} @readOnly={{true}} />
        <span class="rating-count">
          <a href="{{this.user.path}}/feedbacks">
            {{i18n "discourse_user_feedbacks.user_feedbacks.user_ratings_count" count=this.totalCount}}
          </a>
        </span>
      </div>
    {{/if}}
  </template>
}
