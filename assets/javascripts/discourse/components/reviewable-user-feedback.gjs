import Component from "@glimmer/component";

export default class ReviewableUserFeedback extends Component {
  constructor() {
    super(...arguments);
    console.log("=== ReviewableUserFeedback Component ===");
    console.log("Args:", this.args);
    console.log("Model:", this.args.model);
    console.log("Model keys:", this.args.model ? Object.keys(this.args.model) : "no model");
    console.log("Payload:", this.args.model?.payload);
  }

  <template>
    <div class="post-contents-wrapper">
      <div class="reviewable-user-feedback-info" style="background: #333; padding: 20px;">
        <div class="feedback-meta">
          <div><strong>DEBUG - Has model:</strong> {{if @model "YES" "NO"}}</div>
          <div><strong>DEBUG - Has payload:</strong> {{if @model.payload "YES" "NO"}}</div>
          <div><strong>DEBUG - Payload feedback_id:</strong> {{@model.payload.feedback_id}}</div>
          <div><strong>DEBUG - Payload rating:</strong> {{@model.payload.rating}}</div>
          <div><strong>DEBUG - Payload review:</strong> {{@model.payload.review}}</div>

          <hr style="margin: 20px 0;">

          <div><strong>Feedback ID:</strong> #{{@model.payload.feedback_id}}</div>
          <div><strong>User ID:</strong> {{@model.payload.user_id}}</div>
          <div><strong>About User ID:</strong> {{@model.payload.feedback_to_id}}</div>

          {{#if @model.payload.rating}}
            <div class="feedback-rating">
              <strong>Rating:</strong>
              {{@model.payload.rating}}/5 stars
            </div>
          {{/if}}

          {{#if @model.payload.review}}
            <div class="feedback-review">
              <strong>Review:</strong>
              <div class="feedback-review-text">
                {{@model.payload.review}}
              </div>
            </div>
          {{/if}}

          {{#if @model.payload.reason}}
            <div class="flag-reason">
              <strong>Flag Reason:</strong>
              <span class="reason-badge">{{@model.payload.reason}}</span>
            </div>
          {{/if}}

          {{#if @model.payload.message}}
            <div class="flag-message">
              <strong>Additional Details:</strong>
              <div class="flag-message-text">
                {{@model.payload.message}}
              </div>
            </div>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
