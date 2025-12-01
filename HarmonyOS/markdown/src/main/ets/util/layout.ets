// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { LengthMetrics, display, LengthUnit } from "@kit.ArkUI";

export abstract class MDLength {
  private static get density() {
    return display.getDefaultDisplaySync().densityDPI / 160;
  }
  static px2vp(px: number): LengthMetrics {
    return LengthMetrics.vp(px / MDLength.density);
  }
  static vp2px(vp: number): LengthMetrics {
    return LengthMetrics.px(vp * MDLength.density);
  }
  static vp(vp: number): LengthMetrics {
    return LengthMetrics.vp(vp);
  }
  static px(px: number): LengthMetrics {
    return LengthMetrics.px(px);
  }
  static metrics2length(metrics: LengthMetrics): Length {
    if (metrics.unit === LengthUnit.PX) {
      return `${metrics.value}px`;
    } else if (metrics.unit === LengthUnit.VP) {
      return `${metrics.value}vp`;
    } else if (metrics.unit === LengthUnit.FP) {
      return `${metrics.value}fp`;
    } else if (metrics.unit === LengthUnit.LPX) {
      return `${metrics.value}lpx`;
    } else if (metrics.unit === LengthUnit.PERCENT) {
      return `${metrics.value}%`;
    }
    throw Error(`unsupported Length Unit: ${metrics.unit}`);
  }
  static length2metrics(len: Length): LengthMetrics {
    if (typeof len === 'number') {
      return MDLength.vp(len);
    } else if (typeof len === 'string') {
      if (/px$/.test(len)) {
        return LengthMetrics.px(Number(len.slice(0, -2)));
      } else if (/vp$/.test(len)) {
        return LengthMetrics.vp(Number(len.slice(0, -2)));
      } else if (/fp$/.test(len)) {
        return LengthMetrics.fp(Number(len.slice(0, -2)))
      } else if (/lpx$/.test(len)) {
        return LengthMetrics.lpx(Number(len.slice(0, -3)))
      } else if (/%$/.test(len)) {
        return LengthMetrics.percent(Number(len.slice(0, -1)));
      }
    }
    throw Error(`unsupported Length value: ${len}`);
  }
  static length2vp(len: Length): LengthMetrics {
    const metrics = MDLength.length2metrics(len);
    if (metrics.unit === LengthUnit.PX) {
      return MDLength.px2vp(metrics.value);
    } else if (metrics.unit === LengthUnit.VP) {
      return metrics;
    }
    throw Error(`unsupported Length Unit: ${metrics.unit}`);
  }
  static baselineOffsetVP(sizeVP: number, ratio: number = 1/4): LengthMetrics {
    return MDLength.vp(sizeVP * ratio);
  }
}

export interface IMDArea {
  width?: LengthMetrics;
  height?: LengthMetrics;
}
export abstract class MDArea {
  static area(_area: Area): IMDArea {
    return {
      width: MDLength.length2metrics(_area.width),
      height: MDLength.length2metrics(_area.height),
    }
  }
  static metrics2area(spanMetrics: CustomSpanMetrics): IMDArea {
    return {
      width: MDLength.vp(spanMetrics.width),
      height: spanMetrics.height !== undefined ? MDLength.vp(spanMetrics.height) : undefined,
    }
  }
  static area2metrics(area: IMDArea): CustomSpanMetrics {
    return {
      width: area.width ? MDLength.length2vp(MDLength.metrics2length(area.width)).value : 0,
      height: area.height ? MDLength.length2vp(MDLength.metrics2length(area.height)).value : undefined,
    }
  }
  static isEmpty(area?: IMDArea): boolean {
    return !area || (area.width === undefined && area.height === undefined);
  }
  static isAreaContainFinger(area?: Area, finger?: FingerInfo): boolean {
    if (area && finger) {
      const finger_x = MDLength.px2vp(finger.globalX);
      const finger_y = MDLength.px2vp(finger.globalY);
      if (area.globalPosition.x && area.globalPosition.y) {
        const area_x = MDLength.length2vp(area.globalPosition.x);
        const area_y = MDLength.length2vp(area.globalPosition.y);
        const area_w = MDLength.length2vp(area.width);
        const area_h = MDLength.length2vp(area.height);
        if (finger_x.value >= area_x.value && finger_x.value <= area_x.value + area_w.value) {
          if (finger_y.value >= area_y.value && finger_y.value <= area_y.value + area_h.value) {
            return true;
          }
        }
      }
    }
    return false;
  }
}

export abstract class MDPosition {
  static spanMetrics2position(spanMetrics?: CustomSpanMetrics): Position {
    return {
      x: spanMetrics?.width !== undefined ? MDLength.metrics2length(MDLength.vp(spanMetrics.width)) : undefined,
      y: spanMetrics?.height !== undefined ? MDLength.metrics2length(MDLength.vp(spanMetrics.height)) : undefined,
    };
  }
}

export abstract class MDMargin {
  static lengthMargin(margin: IMDMargin): Margin {
    return {
      top: margin.top ? MDLength.metrics2length(margin.top) : undefined,
      left: margin.left ? MDLength.metrics2length(margin.left) : undefined,
      right: margin.right ? MDLength.metrics2length(margin.right) : undefined,
      bottom: margin.bottom ? MDLength.metrics2length(margin.bottom) : undefined,
    };
  }
  static lengthPadding(padding: IMDMargin): Padding {
    return MDMargin.lengthMargin(padding);
  }
}
export interface IMDMargin {
  left?: LengthMetrics;
  top?: LengthMetrics;
  right?: LengthMetrics;
  bottom?: LengthMetrics;
}