import Component from "@glimmer/component";

export default class ReviewableUserFeedbackBody extends Component {
  <template>
    <div class="post-contents-wrapper">
      <div class="reviewable-user-feedback-info">
        <div class="feedback-meta">
          <strong>Feedback from:</strong>
          {{#if @reviewable.target_created_by}}
            {{@reviewable.target_created_by.username}}
          {{else}}
            Unknown
          {{/if}}
          →
          <strong>About:</strong>
          {{#if @reviewable.target_feedback_to}}
            {{@reviewable.target_feedback_to.username}}
          {{else}}
            User
          {{/if}}
        </div>

        {{#if @reviewable.target.rating}}
          <div class="feedback-rating">
            <strong>Rating:</strong>
            {{@reviewable.target.rating}}/5 stars
          </div>
        {{/if}}

        {{#if @reviewable.target.review}}
          <div class="feedback-review">
            <strong>Review:</strong>
            <div class="feedback-review-text">
              {{@reviewable.target.review}}
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
  </template>
}
