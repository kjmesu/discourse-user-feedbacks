/* eslint-disable ember/no-classic-components */
import Component from "@ember/component";
import { LinkTo } from "@ember/routing";
import { tagName } from "@ember-decorators/component";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

@tagName("li")
export default class UserFeedback extends Component {
  <template>
    <LinkTo @route="user.feedbacks" @model={{@outletArgs.model}}>
      {{icon "star"}}
      <span>{{i18n "user.feedback.title"}}</span>
    </LinkTo>
  </template>
}
