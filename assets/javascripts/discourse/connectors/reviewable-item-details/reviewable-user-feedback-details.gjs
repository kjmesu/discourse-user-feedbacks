import { eq } from "truth-helpers";
import ReviewableUserFeedback from "../../components/reviewable-user-feedback";

const ReviewableUserFeedbackDetails = <template>
  {{#if (eq @outletArgs.reviewable.type "ReviewableUserFeedback")}}
    <ReviewableUserFeedback @reviewable={{@outletArgs.reviewable}} />
  {{/if}}
</template>;

export default ReviewableUserFeedbackDetails;
