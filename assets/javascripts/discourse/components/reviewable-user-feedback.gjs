import Component from "@glimmer/component";

export default class ReviewableUserFeedback extends Component {
  get reasonLabel() {
    const reason = this.args.reviewable?.payload?.reason;
    if (reason === "inappropriate") return "Inappropriate";
    if (reason === "fraudulent_transaction") return "Fraudulent Transaction";
    if (reason === "other") return "Other";
    return reason;
  }

  <template>
    <div class="post-body">
      <div class="reviewable-user-feedback">
        {{#if @reviewable.payload.review}}
          <div class="post-contents">
            <p>{{@reviewable.payload.review}}</p>
          </div>
        {{/if}}

        <div class="reviewable-meta-data">
          {{#if @reviewable.payload.rating}}
            <div class="reviewable-field">
              <span class="field-label">Rating:</span>
              <span class="field-value">{{@reviewable.payload.rating}}/5 stars</span>
            </div>
          {{/if}}

          <div class="reviewable-field">
            <span class="field-label">Feedback ID:</span>
            <span class="field-value">#{{@reviewable.payload.feedback_id}}</span>
          </div>

          <div class="reviewable-field">
            <span class="field-label">From User ID:</span>
            <span class="field-value">{{@reviewable.payload.user_id}}</span>
          </div>

          <div class="reviewable-field">
            <span class="field-label">About User ID:</span>
            <span class="field-value">{{@reviewable.payload.feedback_to_id}}</span>
          </div>

          {{#if @reviewable.payload.reason}}
            <div class="reviewable-field">
              <span class="field-label">Reason:</span>
              <span class="field-value reason-badge">{{this.reasonLabel}}</span>
            </div>
          {{/if}}

          {{#if @reviewable.payload.message}}
            <div class="reviewable-field">
              <span class="field-label">Additional details:</span>
              <span class="field-value">{{@reviewable.payload.message}}</span>
            </div>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
