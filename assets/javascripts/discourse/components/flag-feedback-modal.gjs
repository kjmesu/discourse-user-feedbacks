import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import DModalCancel from "discourse/components/d-modal-cancel";
import i18n from "discourse-common/helpers/i18n";
import RadioButton from "discourse/components/radio-button";
import I18n from "I18n";

export default class FlagFeedbackModal extends Component {
  @service modal;
  @tracked selectedReason = "inappropriate";
  @tracked message = "";
  @tracked isSubmitting = false;

  flagReasons = [
    { id: "inappropriate", labelKey: "discourse_user_feedbacks.reviewables.reasons.inappropriate" },
    { id: "fraudulent_transaction", labelKey: "discourse_user_feedbacks.reviewables.reasons.fraudulent_transaction" },
    { id: "other", labelKey: "discourse_user_feedbacks.reviewables.reasons.other" }
  ];

  @action
  updateReason(reason) {
    this.selectedReason = reason;
  }

  @action
  updateMessage(event) {
    this.message = event.target.value;
  }

  @action
  async submitFlag() {
    if (this.isSubmitting) {
      return;
    }

    // Validate that "other" reason has a message
    if (this.selectedReason === "other" && !this.message.trim()) {
      alert(I18n.t("js.flag_modal.other_requires_message"));
      return;
    }

    this.isSubmitting = true;

    try {
      await ajax(`/user_feedbacks/${this.args.model.feedbackId}/flag`, {
        type: "POST",
        data: {
          reason: this.selectedReason,
          message: this.message
        }
      });

      this.args.model.onSuccess?.();
      this.modal.close();
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isSubmitting = false;
    }
  }

  <template>
    <DModal
      @title={{i18n "discourse_user_feedbacks.flag_modal.title"}}
      @closeModal={{@closeModal}}
      class="flag-feedback-modal"
    >
      <:body>
        <p class="flag-modal-description">
          {{i18n "discourse_user_feedbacks.flag_modal.description"}}
        </p>

        <div class="flag-reasons">
          <label class="flag-reason-label">{{i18n "discourse_user_feedbacks.flag_modal.reason_label"}}</label>
          {{#each this.flagReasons as |reason|}}
            <div class="flag-reason-option">
              <label>
                <RadioButton
                  @value={{reason.id}}
                  @name="flag-reason"
                  @selection={{this.selectedReason}}
                  {{on "click" (fn this.updateReason reason.id)}}
                />
                <span class="reason-text">{{i18n reason.labelKey}}</span>
              </label>
            </div>
          {{/each}}
        </div>

        <div class="flag-message">
          <label for="flag-message-input">{{i18n "discourse_user_feedbacks.flag_modal.message_label"}}</label>
          <textarea
            id="flag-message-input"
            class="flag-message-input"
            placeholder={{i18n "discourse_user_feedbacks.flag_modal.message_placeholder"}}
            value={{this.message}}
            {{on "input" this.updateMessage}}
            rows="4"
          ></textarea>
        </div>
      </:body>

      <:footer>
        <DButton
          @action={{this.submitFlag}}
          @label="discourse_user_feedbacks.flag_modal.submit"
          @disabled={{this.isSubmitting}}
          class="btn-primary"
        />
        <DModalCancel @close={{@closeModal}} />
      </:footer>
    </DModal>
  </template>
}
