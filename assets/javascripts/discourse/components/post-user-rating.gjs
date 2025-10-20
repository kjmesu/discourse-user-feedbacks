import Component from "@glimmer/component";
import RatingInput from "./rating-input";

export default class PostUserRating extends Component {
  get post() {
    return this.args.outletArgs.post;
  }

  get avgRating() {
    return Number(this.post?.user_average_rating ?? 0);
  }

  get ratingCount() {
    return Number(this.post?.user_rating_count ?? 0);
  }

  get feedbacksUrl() {
    return `${this.post?.usernameUrl}/feedbacks`;
  }

  <template>
    <div class="average-ratings">
      <RatingInput @readOnly={{true}} @value={{this.avgRating}} />
      <span class="rating-count">
        <a href={{this.feedbacksUrl}}>
          {{this.totalTrades}} Trades
        </a>
      </span>
    </div>
  </template>
}
