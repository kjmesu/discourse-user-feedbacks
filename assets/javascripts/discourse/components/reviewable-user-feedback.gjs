import Component from "@glimmer/component";

export default class ReviewableUserFeedback extends Component {
  <template>
    <div class="post-contents-wrapper">
      <div class="reviewable-user-feedback-info">
        <div class="feedback-meta">
          <div><strong>Debug - Type:</strong> {{@model.type}}</div>
          <div><strong>Debug - Has Payload:</strong> {{if @model.payload "Yes" "No"}}</div>

          {{#if @model.payload}}
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
          {{else}}
            <div><strong>ERROR:</strong> No payload data available</div>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
