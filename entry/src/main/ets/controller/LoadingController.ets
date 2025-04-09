import GlobalLoading from '../components/GlobalLoading';

export default class LoadingController {
  private mComponent: GlobalLoading = null;

  attach(component: GlobalLoading) {
    this.mComponent = component;
  }

  public showLoading(): void {
    if (this.mComponent) {
      return this.mComponent.showLoading();
    }
  }

  public hideLoading(): void {
    if (this.mComponent) {
      return this.mComponent.hideLoading();
    }
  }
}