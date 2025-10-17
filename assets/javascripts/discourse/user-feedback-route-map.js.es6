export default {
  resource: "user",
  map() {
    this.route("feedbacks");
  }
};

export function additionalRoutes() {
  this.route("feedback", { path: "/feedbacks/:id" });
}
