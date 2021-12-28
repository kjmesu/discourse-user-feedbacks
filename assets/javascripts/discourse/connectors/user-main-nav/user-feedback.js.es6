export default {
  shouldRender(args) {
    if (args.model.id <= 0) {
      return false;
    }

    return true;
  },
};
