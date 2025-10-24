import { registerTopicFooterButton } from "discourse/lib/register-topic-footer-button";
import CreateFeedbackModal from "../components/modal/create-feedback-modal";

export default {
  name: "add-feedback-topic-button",

  initialize(owner) {
    registerTopicFooterButton({
      id: "leave-topic-feedback",
      icon: "star",
      priority: 250,
      label: "discourse_user_feedbacks.leave_feedback_for_creator",
      title: "discourse_user_feedbacks.leave_feedback_for_creator",
      classNames: ["leave-topic-feedback"],
      dependentKeys: ["topic.user_id", "topic.visible", "topic.closed"],

      displayed() {
        const topic = this.topic;
        const currentUser = this.currentUser;

        console.log("=== Topic Feedback Button Check ===");
        console.log("Topic:", topic?.id);
        console.log("Current user:", currentUser?.id);
        console.log("Topic creator:", topic?.user_id);

        // Must be logged in
        if (!currentUser) {
          console.log("HIDDEN: No current user");
          return false;
        }

        // Topic must be valid
        if (!topic || !topic.visible || topic.closed || topic.deleted) {
          console.log("HIDDEN: Topic invalid or closed");
          return false;
        }

        // Don't show to topic creator
        if (topic.user_id === currentUser.id) {
          console.log("HIDDEN: Current user is topic creator");
          return false;
        }

        // Only show to users who have posted in the topic
        // Check if current user has any posts in this topic
        const currentUserPosts = topic.postStream?.posts?.filter(
          (post) => post.user_id === currentUser.id
        );

        console.log("User posts in topic:", currentUserPosts?.length || 0);

        if (currentUserPosts && currentUserPosts.length > 0) {
          console.log("SHOWN: User has posted in topic");
          return true;
        } else {
          console.log("HIDDEN: User has not posted in topic");
          return false;
        }
      },

      action() {
        const modal = owner.lookup("service:modal");
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
  },
};
