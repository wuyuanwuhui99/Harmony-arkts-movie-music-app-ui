import CommentComponent from '../components/CommentComponent';

export default class CommentController {
  private mComponent: CommentComponent = null;

  attach(component: CommentComponent) {
    this.mComponent = component;
  }

  public openInputDialog(): void {
    if (this.mComponent) {
      return this.mComponent.openInputDialog();
    }
  }
}