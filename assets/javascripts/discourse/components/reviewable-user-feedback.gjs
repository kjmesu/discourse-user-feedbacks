import Component from "@glimmer/component";
import ReviewableCreatedBy from "discourse/components/reviewable-created-by";
import ReviewablePostHeader from "discourse/components/reviewable-post-header";
import { htmlSafe } from "@ember/template";

export default class ReviewableUserFeedback extends Component {
  get reasonLabel() {
    const reason = this.args.reviewable?.payload?.reason;
    if (reason === "inappropriate") return "Inappropriate";
    if (reason === "fraudulent_transaction") return "Fraudulent Transaction";
    if (reason === "other") return "Other";
    return reason;
  }

  get cooked() {
    // Convert the plain text review to safe HTML
    const review = this.args.reviewable?.payload?.review;
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
    {{! Follow the same structure as ReviewablePost }}
    <div class="post-contents-wrapper">
      <ReviewableCreatedBy
        @user={{@reviewable.target_created_by}}
        @tagName=""
      />

      <div class="post-contents">
        <ReviewablePostHeader
          @reviewable={{@reviewable}}
          @createdBy={{@reviewable.target_created_by}}
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
                {{#if @reviewable.payload.message}}
                  <th>Additional Details:</th>
                {{/if}}
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>
                  {{#if @reviewable.payload.rating}}
                    {{@reviewable.payload.rating}}/5 stars
                  {{else}}
                    -
                  {{/if}}
                </td>
                <td>#{{@reviewable.payload.feedback_id}}</td>
                <td>
                  {{#if @reviewable.payload.reason}}
                    <span class="reason-badge">{{this.reasonLabel}}</span>
                  {{else}}
                    -
                  {{/if}}
                </td>
                {{#if @reviewable.payload.message}}
                  <td>{{@reviewable.payload.message}}</td>
                {{/if}}
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </template>
}
