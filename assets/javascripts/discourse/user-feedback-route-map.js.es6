export default {
  resource: "user",
  map() {
    this.route("feedbacks");
    this.route("feedback", { path: "/feedbacks/:id" });
  },
};
