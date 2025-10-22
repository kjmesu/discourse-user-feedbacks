import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { eq } from "truth-helpers";
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
      alert("Please provide details when selecting 'Other' as the reason.");
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
      @title="Flag Feedback"
      @closeModal={{@closeModal}}
      class="flag-modal"
    >
      <:body>
        <p>{{i18n "flagging.notify_staff"}}</p>

        <div class="flag-types">
          {{#each this.flagReasons as |reason|}}
            <div class="radio-item">
              <RadioButton
                @value={{reason.id}}
                @name="flag-reason"
                @selection={{this.selectedReason}}
                {{on "click" (fn this.updateReason reason.id)}}
              />
              <label>
                <strong>{{i18n reason.labelKey}}</strong>
                {{#if (eq reason.id "inappropriate")}}
                  <div class="description">This feedback contains content that a reasonable person would consider offensive, abusive, or a violation of our community guidelines.</div>
                {{else if (eq reason.id "fraudulent_transaction")}}
                  <div class="description">This feedback appears to be related to a fraudulent or suspicious transaction.</div>
                {{else if (eq reason.id "other")}}
                  <div class="description">This feedback requires staff attention for another reason not listed above.</div>
                {{/if}}
              </label>
            </div>
          {{/each}}
        </div>

        {{#if (eq this.selectedReason "other")}}
          <div class="flag-message-area">
            <label for="flag-message-input">Additional information:</label>
            <textarea
              id="flag-message-input"
              class="flag-message-input"
              placeholder="Please provide more details..."
              value={{this.message}}
              {{on "input" this.updateMessage}}
              rows="4"
            ></textarea>
          </div>
        {{else}}
          <div class="flag-message-area">
            <label for="flag-message-input">Optional additional information:</label>
            <textarea
              id="flag-message-input"
              class="flag-message-input"
              placeholder="Optionally, provide more details..."
              value={{this.message}}
              {{on "input" this.updateMessage}}
              rows="4"
            ></textarea>
          </div>
        {{/if}}
      </:body>

      <:footer>
        <DButton
          @action={{this.submitFlag}}
          @label="flagging.action"
          @disabled={{this.isSubmitting}}
          class="btn-primary"
        />
        <DModalCancel @close={{@closeModal}} />
      </:footer>
    </DModal>
  </template>
}
