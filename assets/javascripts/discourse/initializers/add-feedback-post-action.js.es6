import { apiInitializer } from "discourse/lib/api";
import CreateFeedbackModal from "../components/modal/create-feedback-modal";

export default apiInitializer("1.14.0", (api) => {
  api.registerValueTransformer("post-menu-buttons", ({ value: buttons, context }) => {
    const currentUser = api.getCurrentUser();
    if (!currentUser) {
      return buttons;
    }

    const post = context.post;
    const topic = context.topic || post?.topic;

    if (!post || !topic) {
      console.log("Feedback button: missing post or topic", { post, topic, context });
      return buttons;
    }

    // Don't show feedback button for own posts
    if (post.user_id === currentUser.id) {
      console.log("Feedback button: own post, skipping");
      return buttons;
    }

    // Topic must be valid (not deleted, hidden, or closed)
    if (!topic.visible || topic.closed) {
      console.log("Feedback button: topic not visible or closed", { visible: topic.visible, closed: topic.closed });
      return buttons;
    }

    const isTopicCreator = topic.user_id === currentUser.id;
    const isFirstPost = post.post_number === 1;

    console.log("Feedback button check:", {
      postNumber: post.post_number,
      postUserId: post.user_id,
      topicUserId: topic.user_id,
      currentUserId: currentUser.id,
      isTopicCreator,
      isFirstPost
    });

    let shouldShow = false;

    if (isTopicCreator && !isFirstPost) {
      // Topic creator can leave feedback on any post except post #1
      shouldShow = true;
      console.log("Feedback button: showing for topic creator on reply");
    } else if (!isTopicCreator && isFirstPost) {
      // Non-creators can only leave feedback on post #1 (for the topic creator)
      shouldShow = true;
      console.log("Feedback button: showing for non-creator on post #1");
    }

    if (!shouldShow) {
      console.log("Feedback button: not showing based on rules");
      return buttons;
    }

    // Add the feedback button
    buttons.push({
      id: "leave-feedback",
      icon: "star",
      label: "discourse_user_feedbacks.leave_feedback_button",
      title: "discourse_user_feedbacks.leave_feedback",
      className: "leave-feedback",
      position: "first",
      action: (clickedPost) => {
        // Get modal service from the container
        const modal = api.container.lookup("service:modal");

        modal.show(CreateFeedbackModal, {
          model: {
            post: clickedPost,
            topic: clickedPost.topic,
            feedbackToUserId: clickedPost.user_id,
            feedbackToUsername: clickedPost.username
          }
        });
      }
    });

    return buttons;
  });
});
