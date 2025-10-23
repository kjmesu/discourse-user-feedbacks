import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
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

export default class FeedbackListItem extends Component {
  @service router;
  @service currentUser;
  @service modal;
  @tracked isFlagged = false;

  constructor() {
    super(...arguments);
    const createdAt = this.args.feedback?.created_at;
    this.createdAtDate = createdAt ? new Date(createdAt) : null;
    this.isFlagged = this.args.feedback?.flagged || false;
  }

  get isHidden() {
    return this.args.feedback?.hidden || false;
  }

  get feedbackClasses() {
    let classes = "topic-post clearfix post--sticky-avatar sticky-avatar post--regular regular";
    if (this.isHidden) {
      classes += " post--hidden post-hidden";
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
    if (!confirm(I18n.t("discourse_user_feedbacks.user_feedbacks.delete_confirm"))) {
      return;
    }
    ajax(`/user_feedbacks/${id}`, { type: "DELETE" }).then(() => {
      this.args.onDelete?.(id);
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
  showFlagModal(id) {
    // Staff can view the flag modal even if already flagged (shows "can't flag" message)
    // Non-staff should not see the flag button at all if feedback is hidden
    this.router.transitionTo("review.show", this.args.feedback.reviewable_id || id);
  }

  get canShowFlagButton() {
    if (!this.currentUser) {
      return false;
    }

    // Non-staff cannot flag hidden feedback
    if (!this.currentUser.staff && this.isHidden) {
      return false;
    }

    // Can't flag own feedback
    if (this.args.feedback.user.id === this.currentUser.id) {
      return false;
    }

    // Show flag button/count for staff, or flag button for non-staff if not already flagged
    return this.currentUser.staff || !this.isFlagged;
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
                    {{#if this.canShowFlagButton}}
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
                        <button
                          type="button"
                          class="btn no-text btn-flat btn-icon flag-feedback-button"
                          title={{i18n "discourse_user_feedbacks.user_feedbacks.flag_tooltip"}}
                          {{on "click" (fn this.showFlagModal @feedback.id)}}
                        >
                          {{dIcon "flag"}}
                          <span aria-hidden="true">&#8203;</span>
                        </button>
                      </div>
                    {{/if}}
                    {{#if this.currentUser.staff}}
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
                  </div>
                </nav>
              </section>
            </div>
            <section class="post__actions post-actions"></section>
          </div>
        </div>
      </article>
    </div>
  </template>
}
