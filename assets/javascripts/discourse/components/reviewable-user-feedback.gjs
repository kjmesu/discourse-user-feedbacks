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

        <div class="post-body">
          {{#if this.reviewable.payload.review}}
              <p>{{this.reviewable.payload.review}}</p>
          {{/if}}
        </div>
        {{yield}}
      </div>
    </div>
  </template>
}