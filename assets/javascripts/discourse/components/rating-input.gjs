import Component from "@glimmer/component";

export default class RatingInput extends Component {
  rating = this.args.post.user_average_rating;
  
  get checkedOne() {
    return this.rating >= 1;
  }

  get checkedTwo() {
    return this.rating >= 2;
  }

  get checkedThree() {
    return this.rating >= 3;
  }

  get checkedFour() {
    return this.rating >= 4;
  }

  get checkedFive() {
    return this.rating >= 5;
  }

  get percentageOne() {

    if (this.rating > 0 && this.rating < 1) {
      return ((Math.round(this.rating * 100) / 100) % 1) * 100;
    }
    return 0;
  }

  get percentageTwo() {
    if (this.rating > 1 && this.rating < 2) {
      return ((Math.round(this.rating * 100) / 100) % 1) * 100;
    }
    return 0;
  }

  get percentageThree() {
    if (this.rating > 2 && this.rating < 3) {
      return ((Math.round(this.rating * 100) / 100) % 1) * 100;
    }
    return 0;
  }

  get percentageFour() {
    if (this.rating > 3 && this.rating < 4) {
      return ((Math.round(this.rating * 100) / 100) % 1) * 100;
    }
    return 0;
  }

  get percentageFive() {
    if (this.rating > 4 && this.rating < 5) {
      return ((Math.round(this.rating * 100) / 100) % 1) * 100;
    }
    return 0;
  }   

  <template>
      <div class="average-ratings">
      <div class="rating">
        <span class="icon {{if this.checkedOne "checked"}} {{if this.percentageOne "partial"}} {{if this.readOnly "read-only"}}" {{on "click" (fn this.changeRating 1)}}>
          ☆
          <span class="partial-fill" style="width:{{this.percentageOne}}%;">★</span>
        </span>
        <span class="icon {{if this.checkedTwo "checked"}} {{if this.percentageTwo "partial"}} {{if this.readOnly "read-only"}}" {{on "click" (fn this.changeRating 2)}}>
          ☆
          <span class="partial-fill" style="width:{{this.percentageTwo}}%;">★</span>
        </span>
        <span class="icon {{if this.checkedThree "checked"}} {{if this.percentageThree "partial"}} {{if this.readOnly "read-only"}}" {{on "click" (fn this.changeRating 3)}}>
          ☆
          <span class="partial-fill" style="width:{{this.percentageThree}}%;">★</span>
        </span>
        <span class="icon {{if this.checkedFour "checked"}} {{if this.percentageFour "partial"}} {{if this.readOnly "read-only"}}" {{on "click" (fn this.changeRating 4)}}>
          ☆
          <span class="partial-fill" style="width:{{this.percentageFour}}%;">★</span>
        </span>
        <span class="icon {{if this.checkedFive "checked"}} {{if this.percentageFive "partial"}} {{if this.readOnly "read-only"}}" {{on "click" (fn this.changeRating 5)}}>
          ☆
          <span class="partial-fill" style="width:{{this.percentageFive}}%;">★</span>
        </span>
      </div>
    </div>
  </template>
}
