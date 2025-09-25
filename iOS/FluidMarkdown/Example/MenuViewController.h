// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuViewController:UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
