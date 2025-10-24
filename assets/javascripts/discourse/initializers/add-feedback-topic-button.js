import { withPluginApi } from "discourse/lib/plugin-api";
import { registerTopicFooterButton } from "discourse/lib/register-topic-footer-button";
import CreateFeedbackModal from "../components/modal/create-feedback-modal";

export default {
  name: "add-feedback-topic-button",

  initialize(container) {
    withPluginApi("0.8.31", (api) => {
      registerTopicFooterButton({
        id: "leave-topic-feedback",
        icon: "star",
        priority: 250,
        label: "discourse_user_feedbacks.leave_feedback_for_creator",
        title: "discourse_user_feedbacks.leave_feedback_for_creator",
        classNames: ["leave-topic-feedback"],

        displayed() {
          const topic = this.topic;
          const currentUser = this.currentUser;

          // Must be logged in
          if (!currentUser) {
            return false;
          }

          // Topic must be valid
          if (!topic || !topic.visible || topic.closed || topic.deleted) {
            return false;
          }

          // Don't show to topic creator
          if (topic.user_id === currentUser.id) {
            return false;
          }

          // Only show to users who have posted in the topic
          // Check if current user has any posts in this topic
          const currentUserPosts = topic.postStream?.posts?.filter(
            (post) => post.user_id === currentUser.id
          );

          return currentUserPosts && currentUserPosts.length > 0;
        },

        action() {
          const modal = container.lookup("service:modal");
          const topic = this.topic;

          // Get the topic creator's first post (post #1)
          const firstPost = topic.postStream?.posts?.find(
            (post) => post.post_number === 1
          );

          if (!firstPost) {
            return;
          }

          modal.show(CreateFeedbackModal, {
            model: {
              post: firstPost,
              topic: topic,
              feedbackToUserId: topic.user_id,
              feedbackToUsername: topic.details?.created_by?.username,
            },
          });
        },
      });
    });
  },
};
