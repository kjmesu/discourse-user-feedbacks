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
              <div class="field-label">Rating:</div>
              <div class="field-value">{{@reviewable.payload.rating}}/5 stars</div>
            </div>
          {{/if}}

          <div class="reviewable-field">
            <div class="field-label">Feedback ID:</div>
            <div class="field-value">#{{@reviewable.payload.feedback_id}}</div>
          </div>

          <div class="reviewable-field">
            <div class="field-label">From User ID:</div>
            <div class="field-value">{{@reviewable.payload.user_id}}</div>
          </div>

          <div class="reviewable-field">
            <div class="field-label">About User ID:</div>
            <div class="field-value">{{@reviewable.payload.feedback_to_id}}</div>
          </div>

          {{#if @reviewable.payload.reason}}
            <div class="reviewable-field">
              <div class="field-label">Reason:</div>
              <div class="field-value">
                <span class="reason-badge">{{this.reasonLabel}}</span>
              </div>
            </div>
          {{/if}}

          {{#if @reviewable.payload.message}}
            <div class="reviewable-field">
              <div class="field-label">Additional details:</div>
              <div class="field-value">{{@reviewable.payload.message}}</div>
            </div>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
