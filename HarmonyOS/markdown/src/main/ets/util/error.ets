// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

interface IMDError {
  message?: string;
  code?: number;
  domain?: string;
}
export class MDError extends Error {
  private  option?: IMDError;
  constructor(option?: IMDError) {
    super(option?.message);
    this.option = option;
  }
  get code() {
    return this.option?.code;
  }
  get domain() {
    return this.option?.domain;
  }
}
export interface IMDResult<T> {
  data?: T;
  error?: MDError;
}