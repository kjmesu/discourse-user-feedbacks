export default {
  shouldRender(args) {
    if (args.user.id <= 0) {
      return false;
    }

    return true;
  },
};
