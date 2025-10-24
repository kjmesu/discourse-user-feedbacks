import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import CreateFeedbackModal from "discourse/plugins/discourse-user-feedbacks/discourse/components/modal/create-feedback-modal";

export default class PostMenuLeaveFeedbackButton extends Component {
  @service modal;
  @service currentUser;

  static shouldRender(args, helper) {
    const { post } = args;
    const topic = args.topic || post?.topic;

    if (!helper.currentUser) {
      return false;
    }

    if (!post || !topic) {
      return false;
    }

    // Don't show feedback button for own posts
    if (post.user_id === helper.currentUser.id) {
      return false;
    }

    // Topic must be valid (not deleted, hidden, or closed)
    if (!topic.visible || topic.closed) {
      return false;
    }

    const isTopicCreator = topic.user_id === helper.currentUser.id;
    const isFirstPost = post.post_number === 1;
    const isPostByTopicCreator = post.user_id === topic.user_id;

    // Topic creators can leave feedback on any participant's post (except post #1)
    if (isTopicCreator && !isFirstPost) {
      return true;
    }

    // Participants can leave feedback on ANY post by the topic creator
    // (They must have posted in the topic - enforced by backend Guardian)
    if (!isTopicCreator && isPostByTopicCreator) {
      return true;
    }

    return false;
  }

  @action
  showFeedbackModal() {
    const post = this.args.post;

    this.modal.show(CreateFeedbackModal, {
      model: {
        post: post,
        topic: post.topic,
        feedbackToUserId: post.user_id,
        feedbackToUsername: post.username
      }
    });
  }

  <template>
    <DButton
      class="post-action-menu__leave-feedback leave-feedback"
      ...attributes
      @action={{this.showFeedbackModal}}
      @icon="star"
      @label={{if @showLabel "discourse_user_feedbacks.leave_feedback_button"}}
      @title="discourse_user_feedbacks.leave_feedback"
    />
  </template>
}
