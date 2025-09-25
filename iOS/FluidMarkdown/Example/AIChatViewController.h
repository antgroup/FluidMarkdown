//
//  AIChatViewController.h
//  FluidMarkdownWidget
//
//  Created by hejin on 2025/9/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *sendMessages;
@property (nonatomic, strong) NSMutableArray *reciveMessages;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UITextField *messageField;
@property (nonatomic, strong) UIButton *sendButton;

@end

NS_ASSUME_NONNULL_END
