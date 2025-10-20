import Component from "@glimmer/component";
import { service } from "@ember/service";
import i18n from "discourse-common/helpers/i18n";
import RatingInput from "discourse/plugins/discourse-user-feedbacks/discourse/components/rating-input";

export default class AverageRatingsProfile extends Component {
  @service siteSettings;

  get model() {
    return this.args?.outletArgs?.model;
  }

  get shouldRender() {
    const m = this.model;
    if (!m || m.id <= 0) {
      return false;
    }
    return this.siteSettings.user_feedbacks_display_average_ratings_on_profile;
  }

  get totalCount() {
    const base = Number(this.model?.rating_count || 0);
    const legacy = Number(this.model?.legacy_trade_count || 0);
    return base + legacy;
  }

  <template>
    {{#if this.shouldRender}}
      <div class="average-ratings">
        <RatingInput @value={{this.model.average_rating}} @readOnly={{true}} />
        <span class="rating-count">
          <a href="{{this.model.path}}/feedbacks">
            {{i18n "discourse_user_feedbacks.user_feedbacks.user_ratings_count" count=this.totalCount}}
          </a>
        </span>
      </div>
    {{/if}}
  </template>
}
