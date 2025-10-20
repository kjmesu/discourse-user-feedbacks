import Component from "@glimmer/component";
import { service } from "@ember/service";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import I18n from "I18n";
import { later } from "@ember/runloop";

export default class FeedbackComponent extends Component {
  @service router;
  
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
    <div class="feedback-item">
      {{! Add your template content here }}
      <RelativeDate @date={{this.createdAtDate}} />
      
      {{! Example structure - adjust to match your actual template }}
      <div class="feedback-content">
        {{@feedback.content}}
      </div>
      
      <div class="feedback-actions">
        <div class="permalink-button-wrapper">
          <button 
            type="button"
            class="permalink-button"
            {{on "click" (fn this.copyPermalink @feedback.id)}}
          >
            <span class="permalink-check"></span>
            Copy Link
          </button>
          <span class="permalink-message">Link copied!</span>
        </div>
        
        <button 
          type="button"
          class="delete-button"
          {{on "click" (fn this.deleteFeedback @feedback.id)}}
        >
          Delete
        </button>
      </div>
    </div>
  </template>
}
