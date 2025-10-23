import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DropdownMenu from "discourse/components/dropdown-menu";

export default class AdminFeedbackMenu extends Component {
  @service currentUser;

  get reviewUrl() {
    return `/review?topic_id=${this.args.data.feedback.id}&status=all`;
  }

  @action
  async feedbackAction(actionName) {
    await this.args.close();
    try {
      await this.args.data[actionName]?.();
    } catch (error) {
      console.error(`Unknown error while attempting \`${actionName}\`:`, error);
    }
  }

  <template>
    <DropdownMenu as |dropdown|>
      {{#if this.currentUser.staff}}
        <dropdown.item>
          <DButton
            @label="review.moderation_history"
            @icon="list"
            class="btn btn-transparent moderation-history"
            @href={{this.reviewUrl}}
          />
        </dropdown.item>
      {{/if}}

      {{#if @data.feedback.can_edit}}
        <dropdown.item>
          <DButton
            @icon="user-shield"
            @label={{if
              @data.feedback.notice
              "post.controls.change_post_notice"
              "post.controls.add_post_notice"
            }}
            class={{if @data.feedback.notice "btn btn-transparent change-notice btn-success" "btn btn-transparent add-notice"}}
            @action={{fn this.feedbackAction "changeNotice"}}
          />
        </dropdown.item>
      {{/if}}

      {{#if (and this.currentUser.staff @data.feedback.hidden)}}
        <dropdown.item>
          <DButton
            @label="post.controls.unhide"
            @icon="far-eye"
            class="btn btn-transparent unhide-feedback"
            @action={{fn this.feedbackAction "unhideFeedback"}}
          />
        </dropdown.item>
      {{/if}}
    </DropdownMenu>
  </template>
}
