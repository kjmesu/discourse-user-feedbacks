import Component from "@glimmer/component";
import PostUserRating from "./post-user-rating";

export default class PostUserFeedbackBadge extends Component {
  get post() {
    return this.args.post;
  }

  get totalTrades() {
    const legacy = Number(this.post?.legacy_trade_count ?? 0);
    const ratings = Number(this.post?.user_rating_count ?? 0);
    return legacy + ratings;
  }

  <template>
    <div class="average-ratings">
      <PostUserRating @post={{this.post}} />
      <span class="rating-count">
        <a href="{{this.post.usernameUrl}}/feedbacks">
          {{this.totalTrades}} Trades
        </a>
      </span>
    </div>
  </template>
}
