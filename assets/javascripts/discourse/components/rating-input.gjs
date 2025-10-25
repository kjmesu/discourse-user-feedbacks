import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";

export default class RatingInput extends Component {
  @tracked value = 0;

  constructor() {
    super(...arguments);
    this.value = this.args.value || 0;
  }

  get checkedOne() {
    return parseInt(this.value) >= 1;
  }

  get checkedTwo() {
    return parseInt(this.value) >= 2;
  }

  get checkedThree() {
    return parseInt(this.value) >= 3;
  }

  get checkedFour() {
    return parseInt(this.value) >= 4;
  }

  get checkedFive() {
    return parseInt(this.value) >= 5;
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
  changeRating(ratingValue) {
    if (this.args.readOnly) {
      return;
    }

    this.value = ratingValue;

    // Call onChange callback if provided
    if (this.args.onChange) {
      this.args.onChange(this.value);
    }
  }

  <template>
    <div class="rating user-ratings">
      <span
        class="icon {{if this.checkedOne 'checked'}} {{if this.percentageOne 'partial'}} {{if @readOnly 'read-only'}}"
        {{on "click" (fn this.changeRating 1)}}
      >
        ☆
        <span class="partial-fill" style="width:{{this.percentageOne}}%;">★</span>
      </span>
      <span
        class="icon {{if this.checkedTwo 'checked'}} {{if this.percentageTwo 'partial'}} {{if @readOnly 'read-only'}}"
        {{on "click" (fn this.changeRating 2)}}
      >
        ☆
        <span class="partial-fill" style="width:{{this.percentageTwo}}%;">★</span>
      </span>
      <span
        class="icon {{if this.checkedThree 'checked'}} {{if this.percentageThree 'partial'}} {{if @readOnly 'read-only'}}"
        {{on "click" (fn this.changeRating 3)}}
      >
        ☆
        <span class="partial-fill" style="width:{{this.percentageThree}}%;">★</span>
      </span>
      <span
        class="icon {{if this.checkedFour 'checked'}} {{if this.percentageFour 'partial'}} {{if @readOnly 'read-only'}}"
        {{on "click" (fn this.changeRating 4)}}
      >
        ☆
        <span class="partial-fill" style="width:{{this.percentageFour}}%;">★</span>
      </span>
      <span
        class="icon {{if this.checkedFive 'checked'}} {{if this.percentageFive 'partial'}} {{if @readOnly 'read-only'}}"
        {{on "click" (fn this.changeRating 5)}}
      >
        ☆
        <span class="partial-fill" style="width:{{this.percentageFive}}%;">★</span>
      </span>
    </div>
  </template>
}
