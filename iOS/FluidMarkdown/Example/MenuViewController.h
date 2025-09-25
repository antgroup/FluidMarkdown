//
//  MenuViewController.h
//  FluidMarkdownWidget
//
//  Created by hejin on 2025/9/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuViewController:UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
