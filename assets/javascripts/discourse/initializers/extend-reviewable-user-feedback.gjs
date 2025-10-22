import { apiInitializer } from "discourse/lib/api";
import ReviewableUserFeedbackBody from "../components/reviewable-user-feedback-body";

export default apiInitializer("1.8.0", (api) => {
  api.registerReviewableItemComponent(
    "ReviewableUserFeedback",
    ReviewableUserFeedbackBody
  );
});
