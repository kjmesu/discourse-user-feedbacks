import Component from "@glimmer/component";

export default class ReviewableUserFeedback extends Component {
  <template>
    <div class="post-contents-wrapper">
      <div class="reviewable-user-feedback-info">
        <div class="feedback-meta">
          <div><strong>Feedback ID:</strong> #{{@reviewable.payload.feedback_id}}</div>
          <div><strong>User ID:</strong> {{@reviewable.payload.user_id}}</div>
          <div><strong>About User ID:</strong> {{@reviewable.payload.feedback_to_id}}</div>

          {{#if @reviewable.payload.rating}}
            <div class="feedback-rating">
              <strong>Rating:</strong>
              {{@reviewable.payload.rating}}/5 stars
            </div>
          {{/if}}

          {{#if @reviewable.payload.review}}
            <div class="feedback-review">
              <strong>Review:</strong>
              <div class="feedback-review-text">
                {{@reviewable.payload.review}}
              </div>
            </div>
          {{/if}}

          {{#if @reviewable.payload.reason}}
            <div class="flag-reason">
              <strong>Flag Reason:</strong>
              <span class="reason-badge">{{@reviewable.payload.reason}}</span>
            </div>
          {{/if}}

          {{#if @reviewable.payload.message}}
            <div class="flag-message">
              <strong>Additional Details:</strong>
              <div class="flag-message-text">
                {{@reviewable.payload.message}}
              </div>
            </div>
          {{/if}}
        </div>
      </div>
    </div>
  </template>
}
