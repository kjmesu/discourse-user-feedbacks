/* eslint-disable ember/no-classic-components */
import Component from "@ember/component";
import ReviewableCreatedBy from "discourse/components/reviewable-created-by";
import ReviewablePostHeader from "discourse/components/reviewable-post-header";
import ReviewableScores from "discourse/components/reviewable-scores";
import { i18n } from "discourse-i18n";

export default class ReviewableUserFeedback extends Component {
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

        <div class="post-body">
          <div class="reviewable-feedback-metadata">
            <div class="field">
              <span class="label">Rating:</span>
              <span class="value">
                {{#if this.reviewable.payload.rating}}
                  {{this.reviewable.payload.rating}}/5 stars
                {{else}}
                  -
                {{/if}}
              </span>
            </div>
            <div class="field">
              <span class="label">Feedback ID:</span>
              <span class="value">{{this.reviewable.payload.feedback_id}}</span>
            </div>
            <div class="field">
              <span class="label">Flag Reason:</span>
              <span class="value">
                {{#if this.reviewable.payload.reason}}
                  {{this.reviewable.payload.reason}}
                {{else}}
                  -
                {{/if}}
              </span>
            </div>
            {{#if this.reviewable.payload.message}}
              <div class="field">
                <span class="label">Additional Details:</span>
                <span class="value">{{this.reviewable.payload.message}}</span>
              </div>
            {{/if}}
          </div>
        </div>

        <ReviewableScores @reviewable={{this.reviewable}} @tagName="" />
      </div>
    </div>
  </template>
}
