/* eslint-disable ember/no-classic-components */
import Component from "@ember/component";
import ReviewableCreatedBy from "discourse/components/reviewable-created-by";
import ReviewableField from "discourse/components/reviewable-field";
import ReviewablePostHeader from "discourse/components/reviewable-post-header";
import { htmlSafe } from "@ember/template";
import { i18n } from "discourse-i18n";

export default class ReviewableUserFeedback extends Component {
  get reasonLabel() {
    const reason = this.reviewable?.payload?.reason;
    if (reason === "inappropriate") return i18n("flagging.inappropriate.title");
    if (reason === "fraudulent_transaction") return i18n("user_feedbacks.flag_reasons.fraudulent_transaction");
    if (reason === "other") return i18n("flagging.notify_action");
    return reason;
  }

  get ratingDisplay() {
    const rating = this.reviewable?.payload?.rating;
    return rating ? `${rating}/5 stars` : "-";
  }

  <template>
    <div class="post-contents-wrapper">
      <ReviewableCreatedBy @user={{this.reviewable.target_created_by}} />
      <div class="post-contents">
        <ReviewablePostHeader
          @reviewable={{this.reviewable}}
          @createdBy={{this.reviewable.target_created_by}}
          @tagName=""
        />

        {{#if this.reviewable.payload.review}}
          <div class="post-body">
            <p>{{this.reviewable.payload.review}}</p>
          </div>
        {{/if}}

        <div class="reviewable-user-feedback-fields">
          <ReviewableField
            @classes="reviewable-feedback-details rating"
            @name={{i18n "user_feedbacks.rating"}}
            @value={{this.ratingDisplay}}
          />

          <ReviewableField
            @classes="reviewable-feedback-details feedback-id"
            @name={{i18n "user_feedbacks.feedback_id"}}
            @value={{this.reviewable.payload.feedback_id}}
          />

          <ReviewableField
            @classes="reviewable-feedback-details flag-reason"
            @name={{i18n "user_feedbacks.flag_reason"}}
            @value={{this.reasonLabel}}
          />

          {{#if this.reviewable.payload.message}}
            <ReviewableField
              @classes="reviewable-feedback-details additional-details"
              @name={{i18n "user_feedbacks.additional_details"}}
              @value={{this.reviewable.payload.message}}
            />
          {{/if}}
        </div>

        {{yield}}
      </div>
    </div>
  </template>
}
