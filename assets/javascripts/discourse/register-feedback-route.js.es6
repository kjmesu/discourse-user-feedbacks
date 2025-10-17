import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "register-feedback-route",
  initialize() {
    withPluginApi("1.3.0", (api) => {
      api.addRoute("feedback", "/feedbacks/:id");
    });
  },
};
