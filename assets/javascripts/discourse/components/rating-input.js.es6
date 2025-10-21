import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";

export default class RatingInput extends Component {
  @tracked value = 0;

  constructor() {
    super(...arguments);
    // Initialize value (may be a float for average ratings)
    if (this.args.value !== undefined) {
      this.value = Number(this.args.value);
    }
    this.readOnly = this.args.readOnly ?? false;
  }

  get checkedOne() {
    return parseInt(this.value, 10) >= 1;
  }
  get checkedTwo() {
    return parseInt(this.value, 10) >= 2;
  }
  get checkedThree() {
    return parseInt(this.value, 10) >= 3;
  }
  get checkedFour() {
    return parseInt(this.value, 10) >= 4;
  }
  get checkedFive() {
    return parseInt(this.value, 10) >= 5;
  }

  get percentageOne() {
    if (!this.checkedOne) {
      return ((Math.round(this.value * 100) / 100) % 1) * 100;
    }
    return 0;
  }
  get percentageTwo() {
    if (this.checkedOne && !this.checkedTwo) {
      return ((Math.round(this.value * 100) / 100) % 1) * 100;
    }
    return 0;
  }
  get percentageThree() {
    if (this.checkedTwo && !this.checkedThree) {
      return ((Math.round(this.value * 100) / 100) % 1) * 100;
    }
    return 0;
  }
  get percentageFour() {
    if (this.checkedThree && !this.checkedFour) {
      return ((Math.round(this.value * 100) / 100) % 1) * 100;
    }
    return 0;
  }
  get percentageFive() {
    if (this.checkedFour && !this.checkedFive) {
      return ((Math.round(this.value * 100) / 100) % 1) * 100;
    }
    return 0;
  }

  @action
  changeRating(newRating) {
    // Do nothing if read-only
    if (newRating && this.readOnly) {
      return;
    }
    // Update the rating value (if newRating is provided)
    if (newRating > 0) {
      this.value = newRating;
    }
    // Propagate the change to parent if onChange callback is provided
    if (typeof this.args.onChange === "function") {
      this.args.onChange(this.value);
    }
  }
}
