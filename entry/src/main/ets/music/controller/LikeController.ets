import LikeComponent from '../components/LikeComponent';

export default class LikeController {
  private mComponent: LikeComponent = null;

  attach(component: LikeComponent) {
    this.mComponent = component;
  }

  public useLike(): void {
    if (this.mComponent) {
      this.mComponent.useLike();
    }
  }

  public getLikeIndex(): number {
    if (this.mComponent) {
      return this.mComponent.getLikeIndex();
    }
  }
}