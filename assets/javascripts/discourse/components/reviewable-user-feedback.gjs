/* eslint-disable ember/no-classic-components */
import Component from "@ember/component";
import ReviewableCreatedBy from "discourse/components/reviewable-created-by";
import ReviewablePostHeader from "discourse/components/reviewable-post-header";
import { htmlSafe } from "@ember/template";
import { i18n } from "discourse-i18n";

export default class ReviewableUserFeedback extends Component {
  get reasonLabel() {
    const reason = this.reviewable?.payload?.reason;
    if (reason === "inappropriate") return "Inappropriate";
    if (reason === "fraudulent_transaction") return "Fraudulent Transaction";
    if (reason === "other") return "Other";
    return reason;
  }

  get cooked() {
    // Convert the plain text review to safe HTML
    const review = this.reviewable?.payload?.review;
    if (!review) return htmlSafe("<p><em>No review text provided</em></p>");

    // Escape HTML and convert newlines to <br>
    const escaped = review
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\n/g, "<br>");

    return htmlSafe(`<p>${escaped}</p>`);
  }

  <template>
    <div class="flagged-post-header">
      <span class="flagged-feedback-label">{{i18n "reviewables.types.reviewable_user_feedback.title"}}</span>
    </div>

    <div class="post-contents-wrapper">
      <ReviewableCreatedBy @user={{this.reviewable.target_created_by}} />
      <div class="post-contents">
        <ReviewablePostHeader
          @reviewable={{this.reviewable}}
          @createdBy={{this.reviewable.target_created_by}}
          @tagName=""
        />
        <div class="post-body">
          {{this.cooked}}
        </div>
        <div class="post-body reviewable-meta-data">
          <table class="reviewable-scores">
            <thead>
              <tr>
                <th>Rating:</th>
                <th>Feedback ID:</th>
                <th>Flag Reason:</th>
                {{#if this.reviewable.payload.message}}
                  <th>Additional Details:</th>
                {{/if}}
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  {{#if this.reviewable.payload.rating}}
                    {{this.reviewable.payload.rating}}/5 stars
                  {{else}}
                    -
                  {{/if}}
                </td>
                <td>#{{this.reviewable.payload.feedback_id}}</td>
                <td>
                  {{#if this.reviewable.payload.reason}}
                    <span class="reason-badge">{{this.reasonLabel}}</span>
                  {{else}}
                    -
                  {{/if}}
                </td>
                {{#if this.reviewable.payload.message}}
                  <td>{{this.reviewable.payload.message}}</td>
                {{/if}}
              </tr>
            </tbody>
          </table>
        </div>
        {{yield}}
      </div>
    </div>
  </template>
}
