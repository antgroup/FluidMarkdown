//
//  AMViewController.h
//  AntMarkdown
//
//  Created by 谈心 on 10/29/2024.
//  Copyright (c) 2024 谈心. All rights reserved.
//

@import UIKit;

@interface TextView : UITextView

@end

@interface MarkdownCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic) CGSize cellSize;
@property (nonatomic, copy) void (^onSizeUpdate)(CGSize size);
@end

@interface AMViewController : UIViewController

@end
