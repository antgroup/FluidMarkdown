import { resourceManager } from "@kit.LocalizationKit";
import { util } from '@kit.ArkTS';

export abstract class Feature {
  private _meta?: FeatureMeta;
  private static __instance?: Feature;
  static shared() {
    if (!Feature.__instance) {
      Feature.__instance = new FeatureImpl();
    }
    return Feature.__instance;
  }
  private load(ctx: UIContext) {
    const rm = ctx.getHostContext()?.resourceManager;
    if (rm) {
      if (!this._meta) {
        this._meta = {};
        Feature.walk(rm, 'feature', (root, name, content) => {
          let features = this._meta![root];
          if (!features) {
            features = [];
            this._meta![root] = features;
          }
          features.push({ root, name, content });
        });
      }
    }
  }
  private static walk(
    rm: resourceManager.ResourceManager, path: string,
    callback: (root: string, name: string, content: string) => void,
  ) {
    const files = rm.getRawFileListSync(path);
    files.map(ele => `${path}/${ele}`).forEach(ele => {
      if (rm.isRawDir(ele)) {
        Feature.walk(rm, ele, callback);
      } else {
        const name = ele.split(path).join('');
        const content = util.TextDecoder
          .create('utf-8', { fatal: false, ignoreBOM: true })
          .decodeToString(rm.getRawFileContentSync(ele), { stream: false });
        callback(path, name, content);
      }
    });
  }
  meta(ctx: UIContext) {
    this.load(ctx);
    return this._meta;
  }
}
class FeatureImpl extends Feature {}

export type FeatureMeta = Record<string, IFeature[]>;
export interface IFeature {
  root: string;
  name: string;
  content: string;
}