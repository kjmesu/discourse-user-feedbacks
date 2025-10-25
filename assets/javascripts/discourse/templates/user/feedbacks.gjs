import FeedbackListItem from "../../components/feedback-list-item";
import { i18n } from "discourse-i18n";

<template>
  <div class="user-feedbacks-left"></div>
  <div class="user-feedbacks-right">
    {{#if @model.feedbacks.length}}
      {{#each @model.feedbacks as |feedback|}}
        <FeedbackListItem @feedback={{feedback}} />
      {{/each}}
    {{else}}
      <div class="empty-state">
        <span class="empty-state-title">
          {{i18n "discourse_user_feedbacks.user_feedbacks.empty_state_title"}}
        </span>
        <div class="empty-state-body">
          <p>{{i18n "discourse_user_feedbacks.user_feedbacks.empty_state_body"}}</p>
        </div>
      </div>
    {{/if}}
  </div>
</template>
