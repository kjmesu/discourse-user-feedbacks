import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import Component from "@glimmer/component";
import { ajax } from "discourse/lib/ajax";
import i18n from "discourse-common/helpers/i18n";

export default class LegacyTradeInput extends Component {
  @service currentUser;

  get isStaff() {
    return this.currentUser?.staff;
  }

  get legacyTradeCount() {
    return this.args.model?.legacy_trade_count ?? 0;
  }

  @action
  async updateLegacyTradeCount(event) {
    const value = parseInt(event.target.value || 0, 10);

    try {
      await ajax(`/legacy_trades/${this.args.model.id}`, {
        type: "PUT",
        data: { legacy_trade_count: value },
      });
    } catch (e) {
      console.error(e);
    }
  }

  <template>
    {{#if this.isStaff}}
      <div class="control-group legacy-trade-count">
        <label for="legacy-trade-count">
          {{i18n "discourse_user_feedbacks.legacy_trade_count"}}
        </label>
        <input
          id="legacy-trade-count"
          type="number"
          value={{this.legacyTradeCount}}
          {{on "change" this.updateLegacyTradeCount}}
        />
      </div>
    {{/if}}
  </template>
}
