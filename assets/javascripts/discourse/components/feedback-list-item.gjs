import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { htmlSafe } from "@ember/template";
import RelativeDate from "discourse/components/relative-date";
import RatingInput from "discourse/plugins/discourse-user-feedbacks/discourse/components/rating-input";
import I18n from "I18n";
import { later } from "@ember/runloop";

export default class FeedbackListItem extends Component {
  @service router;
  @service currentUser;
  
  get createdAtDate() {
    const createdAt = this.args.feedback?.created_at;
    return createdAt ? new Date(createdAt) : null;
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
  
  <template>
    <div class="topic-post clearfix post--sticky-avatar sticky-avatar post--regular regular">
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
                    <span class="relative-date">
                      <RelativeDate @date={{this.createdAtDate}} @format="tiny" @key={{@feedback.id}} />
                    </span>
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
