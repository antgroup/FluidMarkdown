// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { StyledUserBridgeValue } from './styled-value';

export class StyledController extends TextController {
  setStyledString(value: StyledString): void {
    if (value.length > 0) {
      const styled = value.getStyles(0, value.length, StyledStringKey.USER_DATA)
        .filter(ele => (ele.styledValue instanceof StyledUserBridgeValue))
        .map(ele => (ele.styledValue as StyledUserBridgeValue).object?.deref())
        .pop();
      styled?.currentRoot?.bindTextController(this);
    }
    super.setStyledString(value);
  }
}