import FeedbackListItem from "../components/feedback-list-item";

<template>
  <div class="user-feedback-permalink">
    <FeedbackListItem @feedback={{@model.user_feedback}} />
  </div>
</template>
