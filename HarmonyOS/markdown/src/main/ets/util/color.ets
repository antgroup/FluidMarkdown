// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { drawing } from '@kit.ArkGraphics2D';
import Common2D from '@ohos.graphics.common2D';
import Sys from '@ohos.deviceInfo';
import { ColorMetrics } from '@kit.ArkUI';

export abstract class MDColor {
  static makeColorFromResourceColor(resourceColor: ResourceColor): Common2D.Color {
    if (Sys.sdkApiVersion >= 15) {
      return drawing.Tool.makeColorFromResourceColor(resourceColor);
    } else {
      return { red: 0, green: 0, blue: 0, alpha: 255 };
    }
  }
  //  return 0xARGB
  static toHex(color: ResourceColor): number {
    try {
      const metrics = ColorMetrics.resourceColor(color);
      const r = metrics.red & 0xff;
      const g = metrics.green & 0xff;
      const b = metrics.blue & 0xff;
      const a = metrics.alpha & 0xff;
      return (a << 24) | (r << 16) | (g << 8) | b;
    } catch (e) {
      return 0x000000;
    }
  }
}