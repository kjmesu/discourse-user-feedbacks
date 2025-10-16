import Component from "@ember/component";
import { action } from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNames: ["user-ratings"],
  value: 0,
  checkedOne: false,
  checkedTwo: false,
  checkedThree: false,
  checkedFour: false,
  checkedFive: false,
  percentageOne: 68,

  didReceiveAttrs() {
    this._super(...arguments);
    this.changeRating();
  },

  changeRating(value): action(function() {
    if (value && this.readOnly) return;

    if (value > 0) {
      this.set("value", value);
    } else {
      this.set("value", this.value);
    }
  }),

  @discourseComputed("value")
  checkedOne(value) {
    if (parseInt(value) >= 1) {
      return true;
    }

    return false;
  },

  @discourseComputed("value")
  checkedTwo(value) {
    if (parseInt(value) >= 2) {
      return true;
    }

    return false;
  },

  @discourseComputed("value")
  checkedThree(value) {
    if (parseInt(value) >= 3) {
      return true;
    }

    return false;
  },

  @discourseComputed("value")
  checkedFour(value) {
    if (parseInt(value) >= 4) {
      return true;
    }

    return false;
  },

  @discourseComputed("value")
  checkedFive(value) {
    if (parseInt(value) >= 5) {
      return true;
    }

    return false;
  },

  @discourseComputed("value")
  percentageOne(value) {
    if (!this.checkedOne) {
      return ((Math.round(value * 100) / 100) % 1) * 100;
    }

    return 0;
  },

  @discourseComputed("value")
  percentageTwo(value) {
    if (this.checkedOne && !this.checkedTwo) {
      return ((Math.round(value * 100) / 100) % 1) * 100;
    }

    return 0;
  },

  @discourseComputed("value")
  percentageThree(value) {
    if (this.checkedTwo && !this.checkedThree) {
      return ((Math.round(value * 100) / 100) % 1) * 100;
    }

    return 0;
  },

  @discourseComputed("value")
  percentageFour(value) {
    if (this.checkedThree && !this.checkedFour) {
      return ((Math.round(value * 100) / 100) % 1) * 100;
    }

    return 0;
  },

  @discourseComputed("value")
  percentageFive(value) {
    if (this.checkedFour && !this.checkedFive) {
      return ((Math.round(value * 100) / 100) % 1) * 100;
    }

    return 0;
  },
});
