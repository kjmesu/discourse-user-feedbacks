import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import { set } from "@ember/object";
import { gt } from "@ember/object/computed";
import { htmlSafe } from "@ember/template";
import avatar from "discourse/helpers/avatar";
import dIcon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";
import concatClass from "discourse/helpers/concat-class";
import RelativeDate from "discourse/components/relative-date";
import RatingInput from "discourse/plugins/discourse-user-feedbacks/discourse/components/rating-input";
import DButton from "discourse/components/d-button";
import DiscourseURL from "discourse/lib/url";
import I18n from "I18n";
import { later } from "@ember/runloop";
import FlagFeedbackModal from "discourse/plugins/discourse-user-feedbacks/discourse/components/flag-feedback-modal";
import AdminFeedbackMenu from "discourse/plugins/discourse-user-feedbacks/discourse/components/admin-feedback-menu";
import ChangePostNotice from "discourse/components/modal/change-post-notice";

export default class FeedbackListItem extends Component {
  @service router;
  @service currentUser;
  @service modal;
  @service menu;
  @tracked isFlagged = false;
  @tracked deletedAt = null;
  @tracked deletedBy = null;
  @tracked canDelete = false;
  @tracked canRecover = false;
  @tracked collapsed = true;
  @tracked isHidden = false;

  constructor() {
    super(...arguments);
    const createdAt = this.args.feedback?.created_at;
    this.createdAtDate = createdAt ? new Date(createdAt) : null;
    this.isFlagged = this.args.feedback?.flagged || false;

    // Initialize tracked deletion state
    this.deletedAt = this.args.feedback?.deleted_at ? new Date(this.args.feedback.deleted_at) : null;
    this.deletedBy = this.args.feedback?.deleted_by;
    this.canDelete = this.args.feedback?.can_delete || false;
    this.canRecover = this.args.feedback?.can_recover || false;

    // Initialize tracked hidden state
    this.isHidden = this.args.feedback?.hidden || false;
  }

  get isDeleted() {
    return this.deletedAt !== null;
  }

  get feedbackClasses() {
    let classes = "topic-post clearfix post--sticky-avatar sticky-avatar post--regular regular";
    if (this.isHidden) {
      classes += " post--hidden post-hidden";
    }
    if (this.isDeleted) {
      classes += " post--deleted deleted";
    }
    return classes;
  }

  get showFlaggedMessage() {
    // Show "You flagged this" message if current user flagged it
    return this.isFlagged && this.currentUser && !this.args.feedback.reviewable_id;
  }

  get showFlagCount() {
    return this.currentUser?.staff && this.args.feedback.reviewable_id;
  }

  get hasPendingFlags() {
    return this.args.feedback.reviewable_score_pending_count > 0;
  }

  @action
  navigateToReview() {
    if (this.args.feedback.reviewable_id) {
      DiscourseURL.routeTo(`/review/${this.args.feedback.reviewable_id}`);
    }
  }

  @action
  deleteFeedback(id) {
    // No confirmation modal - delete immediately like posts
    ajax(`/user_feedbacks/${id}`, { type: "DELETE" }).then(() => {
      // Update tracked properties - triggers reactive re-render
      this.deletedAt = new Date();
      this.deletedBy = {
        id: this.currentUser.id,
        username: this.currentUser.username,
        avatar_template: this.currentUser.avatar_template
      };
      this.canDelete = false;
      this.canRecover = true;
    }).catch(popupAjaxError);
  }

  @action
  recoverFeedback(id) {
    ajax(`/user_feedbacks/${id}/recover`, { type: "PUT" }).then((result) => {
      // Update tracked properties - triggers reactive re-render
      this.deletedAt = null;
      this.deletedBy = null;
      this.canDelete = result.user_feedback.can_delete;
      this.canRecover = false;
    }).catch(popupAjaxError);
  }

  @action
  showMoreActions() {
    this.collapsed = false;
  }

  @action
  openAdminMenu(event) {
    this.menu.show(event.currentTarget, {
      component: AdminFeedbackMenu,
      data: {
        feedback: this.args.feedback,
        unhideFeedback: this.unhideFeedback,
        changeNotice: this.changeNotice,
      },
    });
  }

  @action
  async unhideFeedback() {
    try {
      await ajax(`/user_feedbacks/${this.args.feedback.id}/unhide`, {
        type: "PUT",
      });
      // Update tracked state reactively
      this.isHidden = false;
    } catch (error) {
      popupAjaxError(error);
    }
  }

  @action
  async changeNotice() {
    const feedback = this.args.feedback;

    // The standard ChangePostNotice modal expects these methods to exist on the object.
    // We are shimming them here to call our standard `update` action.
    feedback.updatePostField = async (field, value) => {
      if (field !== "notice") {
        throw new Error(`Unsupported field for feedback: ${field}`);
      }
      return ajax(`/user_feedbacks/${feedback.id}`, {
        type: "PUT",
        data: { notice: value },
      });
    };

    feedback.set = (key, value) => {
      set(this.args.feedback, key, value);
    };

    this.modal.show(ChangePostNotice, {
      model: {
        post: feedback,
      },
    });
  }

  @action
  async copyPermalink(id, event) {
    event.preventDefault();
    const element = event.currentTarget;
    const wrapper = element.closest(".permalink-button-wrapper");
    const message = wrapper.querySelector(".permalink-message");
    const check = element.querySelector(".permalink-check");
    const url = `${window.location.origin}${this.router.urlFor("feedback", id)}`;

    try {
      await navigator.clipboard.writeText(url);
    } catch {
      const tempInput = document.createElement("input");
      tempInput.style.position = "absolute";
      tempInput.style.left = "-9999px";
      tempInput.value = url;
      document.body.appendChild(tempInput);
      tempInput.select();
      document.execCommand("copy");
      document.body.removeChild(tempInput);
    }

    check.classList.add("visible");
    element.classList.add("link-copied");
    message.classList.add("visible");

    later(() => {
      check.classList.remove("visible");
      element.classList.remove("link-copied");
      message.classList.remove("visible");
    }, 2000);
  }

  @action
  showFlagModal() {
    // If already under review (has reviewable_id), route to review queue
    if (this.args.feedback.reviewable_id) {
      this.navigateToReview();
      return;
    }

    // Otherwise, open the flag modal for items not currently under review
    this.modal.show(FlagFeedbackModal, {
      model: {
        feedbackId: this.args.feedback.id,
        onSuccess: () => {
          // Update the flagged state after successful flag submission
          this.isFlagged = true;
        }
      }
    });
  }

  get canShowFlagButton() {
    if (!this.currentUser) {
      return false;
    }

    // Can't flag own feedback
    if (this.args.feedback.user.id === this.currentUser.id) {
      return false;
    }

    // Non-staff cannot flag hidden feedback
    if (!this.currentUser.staff && this.isHidden) {
      return false;
    }

    // For items under review (have reviewable_id):
    // - Staff: show flag button (routes to review)
    // - Non-staff: hide entirely
    if (this.args.feedback.reviewable_id) {
      return this.currentUser.staff;
    }

    // For items not under review: show flag button for everyone (except own feedback)
    return true;
  }

  get canShowFlagSection() {
    // Show the flag section if:
    // 1. Can show flag button (unflagged items for all users)
    // 2. Can show flag count (flagged items for staff)
    return this.canShowFlagButton || this.showFlagCount;
  }

  get canManageFeedback() {
    // Staff can manage feedback items
    return this.currentUser?.staff;
  }

  get showMoreButton() {
    // Show the "show more" button (3 dots) when:
    // 1. Menu is in collapsed state
    // 2. There are moderator buttons to show (delete/recover/wrench)
    return this.collapsed && this.canManageFeedback;
  }

  get showModeratorButtons() {
    // Show moderator buttons (delete/recover/wrench) when:
    // 1. Menu is expanded OR
    // 2. User is not staff (non-staff always sees available buttons)
    return !this.collapsed || !this.canManageFeedback;
  }
  
  <template>
    <div class={{this.feedbackClasses}}>
      <article
        id="feedback_{{@feedback.id}}"
        class="boxed onscreen-post feedback-post"
        aria-label="feedback by @{{@feedback.user.username}}"
        role="region"
        data-feedback-id={{@feedback.id}}
        data-user-id={{@feedback.user.id}}
      >
        <div class="post__row row">
          {{! Avatar }}
          <div class="topic-avatar">
            <div class="post-avatar">
              <a
                class="main-avatar"
                tabindex="-1"
                href={{@feedback.user.path}}
                data-user-card={{@feedback.user.username}}
                aria-label="{{@feedback.user.username}}'s profile"
              >
                {{avatar @feedback.user imageSize="medium"}}
              </a>
            </div>
          </div>
          {{! Body }}
          <div class="post__body topic-body clearfix">
            {{! Meta header }}
            <div class="topic-meta-data" role="heading" aria-level="2">
              <div class="names trigger-user-card">
                <span class="first full-name">
                  <a
                    href={{@feedback.user.path}}
                    data-user-card={{@feedback.user.username}}
                    aria-label="{{@feedback.user.username}}'s profile"
                  >
                    {{@feedback.user.username}}
                  </a>
                </span>
                <div class="average-ratings">
                  <RatingInput @value={{@feedback.rating}} @readOnly={{true}} />
                </div>
              </div>
              <div class="post-infos">
                <div class="post-info post-date">
                  <a
                    class="post-date"
                    href="#"
                    title={{i18n "discourse_user_feedbacks.user_feedbacks.feedback_date"}}
                  >
                    <RelativeDate @date={{this.createdAtDate}} @format="tiny" />
                  </a>
                </div>
              </div>
            </div>
            {{! Feedback body }}
            <div class="post__regular regular post__contents contents">
              <div class="cooked">
                <p>{{htmlSafe @feedback.review}}</p>
                <div class="cooked-selection-barrier" aria-hidden="true"><br></div>
              </div>
              {{#if this.showFlaggedMessage}}
                <div class="post-info post-action-feedback">
                  <p class="post-action">
                    {{dIcon "flag"}}
                    <span>{{i18n "discourse_user_feedbacks.user_feedbacks.flagged_as" reason=(i18n "discourse_user_feedbacks.reviewables.reasons.inappropriate")}}</span>
                  </p>
                </div>
              {{/if}}
              {{! Action bar }}
              <section class="post__menu-area post-menu-area clearfix">
                <nav class="post-controls collapsed">
                  <div class="actions">
                    <div class="permalink-button-wrapper">
                      <button
                        type="button"
                        class="btn no-text btn-flat btn-icon permalink-button"
                        title={{i18n "discourse_user_feedbacks.user_feedbacks.copy_title"}}
                        {{on "click" (fn this.copyPermalink @feedback.id)}}
                      >
                        {{dIcon "link"}}
                        <span class="permalink-check">
                          {{dIcon "check"}}
                        </span>
                        <span aria-hidden="true">&#8203;</span>
                      </button>
                      <div class="permalink-message">
                        {{i18n "discourse_user_feedbacks.user_feedbacks.link_copied"}}
                      </div>
                    </div>
                    {{#if this.canShowFlagSection}}
                      <div class="double-button">
                        {{#if this.showFlagCount}}
                          <DButton
                            class={{concatClass
                              "btn-flat btn-icon button-count"
                              (if this.hasPendingFlags "has-pending")
                            }}
                            @action={{this.navigateToReview}}
                            @title="reviewables.view_all"
                          >
                            <span>{{@feedback.reviewable_score_count}}</span>
                          </DButton>
                        {{/if}}
                        {{#if this.canShowFlagButton}}
                          <button
                            type="button"
                            class="btn no-text btn-flat btn-icon flag-feedback-button"
                            title={{i18n "discourse_user_feedbacks.user_feedbacks.flag_tooltip"}}
                            {{on "click" this.showFlagModal}}
                          >
                            {{dIcon "flag"}}
                            <span aria-hidden="true">&#8203;</span>
                          </button>
                        {{/if}}
                      </div>
                    {{/if}}
                    {{#if this.showMoreButton}}
                      <button
                        type="button"
                        class="btn no-text btn-flat btn-icon show-more-actions"
                        title={{i18n "show_more"}}
                        {{on "click" this.showMoreActions}}
                      >
                        {{dIcon "ellipsis"}}
                        <span aria-hidden="true">&#8203;</span>
                      </button>
                    {{/if}}
                    {{#if this.showModeratorButtons}}
                      {{#if this.canManageFeedback}}
                        <button
                          type="button"
                          class="btn no-text btn-flat btn-icon show-feedback-admin-menu"
                          title={{i18n "post.controls.admin"}}
                          {{on "click" this.openAdminMenu}}
                        >
                          {{dIcon "wrench"}}
                          <span aria-hidden="true">&#8203;</span>
                        </button>
                      {{/if}}
                      {{#if this.canRecover}}
                        <button
                          class="btn no-text btn-flat btn-icon recover-feedback-button"
                          title={{i18n "discourse_user_feedbacks.user_feedbacks.recover_tooltip"}}
                          {{on "click" (fn this.recoverFeedback @feedback.id)}}
                          type="button"
                        >
                          {{dIcon "arrow-rotate-left"}}
                          <span aria-hidden="true">&#8203;</span>
                        </button>
                      {{else if this.canDelete}}
                        <button
                          class="btn no-text btn-flat btn-icon btn-danger delete-feedback-button"
                          title={{i18n "discourse_user_feedbacks.user_feedbacks.delete_tooltip"}}
                          {{on "click" (fn this.deleteFeedback @feedback.id)}}
                          type="button"
                        >
                          {{dIcon "trash-can"}}
                          <span aria-hidden="true">&#8203;</span>
                        </button>
                      {{/if}}
                    {{/if}}
                  </div>
                </nav>
              </section>
            </div>
            {{! Deleted post info - OUTSIDE post__contents, matching Discourse post structure }}
            <section class="post__actions post-actions">
              {{#if this.isDeleted}}
                {{#if this.deletedBy}}
                  <div class="post-action deleted-post">
                    {{dIcon "trash-can"}}
                    {{avatar this.deletedBy imageSize="tiny"}}
                    <RelativeDate @date={{this.deletedAt}} @format="tiny" />
                  </div>
                {{/if}}
              {{/if}}
            </section>
          </div>
        </div>
      </article>
    </div>
  </template>
}
