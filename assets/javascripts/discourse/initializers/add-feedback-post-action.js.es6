import { apiInitializer } from "discourse/lib/api";
import PostMenuLeaveFeedbackButton from "../components/post/menu/buttons/leave-feedback";

export default apiInitializer("1.14.0", (api) => {
  api.registerValueTransformer("post-menu-buttons", ({ value: dag, context }) => {
    // Add the leave-feedback button to the DAG
    // Position it after the reply button, before the show-more button
    dag.add(
      "leave-feedback",
      PostMenuLeaveFeedbackButton,
      {
        before: context.buttonKeys?.SHOW_MORE,
        after: context.buttonKeys?.REPLY
      }
    );

    return dag;
  });
});
