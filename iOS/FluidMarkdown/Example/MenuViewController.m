// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.


#import "MenuViewController.h"
#import "StreamPreviewViewController.h"
#import "AIChatViewController.h"


@implementation MenuViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuItems = @[@"stream print preview", @"AI conversation scenario simulation"];
   
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.menuItems[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        StreamPreviewViewController *previewVC = [[StreamPreviewViewController alloc] init];
        [self.navigationController pushViewController:previewVC animated:YES];
    } else if (indexPath.row == 1) {
        AIChatViewController *chatVC = [[AIChatViewController alloc] init];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}
@end
