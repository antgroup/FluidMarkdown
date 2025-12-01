interface INavigation {
  STACK: string,
}
export const NAV: INavigation = {
  STACK: '_nav.stack',
};
export const PAGE_BGCOLOR: ResourceColor = 0xe6f7ff;
export enum EPage {
  FeatureList = 'feature_list',
  FeatureDetail = 'feature_detail',
}