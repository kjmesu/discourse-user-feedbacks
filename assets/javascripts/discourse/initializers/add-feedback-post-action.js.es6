import { withPluginApi } from "discourse/lib/plugin-api";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import showModal from "discourse/lib/show-modal";

function initializeFeedbackPostAction(api) {
  // Add a post action button for leaving feedback
  api.addPostMenuButton("feedback", (post) => {
    const currentUser = api.getCurrentUser();
    if (!currentUser) return;

    const topic = post.topic;
    if (!topic) return;

    // Don't show feedback button for own posts
    if (post.user_id === currentUser.id) return;

    // Topic must be valid (not deleted, hidden, or closed)
    if (!topic.visible || topic.closed) return;

    const isTopicCreator = topic.user_id === currentUser.id;
    const isFirstPost = post.post_number === 1;

    let shouldShow = false;

    if (isTopicCreator && !isFirstPost) {
      // Topic creator can leave feedback on any post except post #1
      shouldShow = true;
    } else if (!isTopicCreator && isFirstPost) {
      // Non-creators can only leave feedback on post #1 (for the topic creator)
      shouldShow = true;
    }

    if (!shouldShow) return;

    return {
      action: "leaveFeedback",
      icon: "star",
      title: "user_feedbacks.leave_feedback",
      label: "user_feedbacks.leave_feedback_button",
      className: "leave-feedback",
      position: "first"
    };
  });

  // Handle the leave feedback action
  api.attachWidgetAction("post", "leaveFeedback", function() {
    const post = this.model;
    const currentUser = api.getCurrentUser();

    if (!currentUser) return;

    // Show modal for creating feedback
    const controller = showModal("create-feedback", {
      model: {
        post: post,
        topic: post.topic,
        feedbackToUserId: post.user_id,
        feedbackToUsername: post.username
      }
    });

    controller.setProperties({
      post: post,
      topic: post.topic,
      feedbackToUserId: post.user_id,
      feedbackToUsername: post.username
    });
  });
}

export default {
  name: "add-feedback-post-action",
  initialize() {
    withPluginApi("0.8.31", initializeFeedbackPostAction);
  }
};
