//
//  AMViewController.m
//  AntMarkdown
//
//  Created by 谈心 on 10/29/2024.
//  Copyright (c) 2024 谈心. All rights reserved.
//

#import <AntMarkdown/AntMarkdown.h>
#import "AMViewController.h"

@implementation TextView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSTextContainer *container = self.textContainer;
        AMLayoutManager *mgr = [AMLayoutManager new];
        NSTextStorage *storage = [[NSTextStorage alloc] init];
        [storage addLayoutManager:mgr];
        [mgr addTextContainer:container];
    }
    return self;
}

@end

@implementation MarkdownCell

- (void)dealloc
{
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.textView removeFromSuperview];
    UITextView *textView = [[UITextView alloc] initWithFrame_ant_mark:self.contentView.bounds];
    [self.contentView addSubview:textView];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.contentView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:textView
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:self.contentView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:textView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:self.contentView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:textView
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:self.contentView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:textView
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                      constant:0],
    ]];
    self.textView = textView;
    self.textView.bounces = NO;
    self.textView.userInteractionEnabled = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    // self.textView.bouncesVertically = NO;
    self.textView.delaysContentTouches = YES;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.textContainer.lineFragmentPadding = 20;
    
    [self.textView addObserver:self
                    forKeyPath:@"contentSize"
                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                       context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        CGSize newSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
        self.cellSize = newSize;
    }
}

- (void)setCellSize:(CGSize)cellSize
{
    if (!CGSizeEqualToSize(_cellSize, cellSize)) {
        _cellSize = cellSize;
        !self.onSizeUpdate ?: self.onSizeUpdate(cellSize);
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
//    self.textView.attributedText = nil;
}

@end

@interface CellModel : NSObject
@property (nonatomic) NSMutableAttributedString *attributedText;
@property (nonatomic) CGSize size;
@end

@implementation CellModel

+ (instancetype)modelWithString:(NSString *)text {
    CellModel *m = [self new];
    m.attributedText = [[NSMutableAttributedString alloc] initWithString:text ?: @""
                                                              attributes:@{
        NSForegroundColorAttributeName: [UIColor blackColor],
    }];
    return m;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(onNoti:)
//                                                     name:AMTextAttachmentSizeDidUpdateNotification
//                                                   object:nil];
    }
    return self;
}

- (void)onNoti:(NSNotification *)noti
{
    NSAttributedString *attr = noti.object;
    if ([attr isKindOfClass:[NSAttributedString class]] && [attr.string isEqualToString:self.attributedText.string]) {
        CGRect rect = [attr boundingRectWithSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width - 40, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics
                                         context:nil];
        self.size = CGRectIntegral(rect).size;
    }
}

@end

@interface AMViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray <CellModel *> *models;
@property (nonatomic) AMTextStyles *styles;
@property (nonatomic) NSInteger cursor;
@end

@implementation AMViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.models = [NSMutableArray arrayWithObjects:
                       [CellModel modelWithString:@"Row1"],
                       [CellModel modelWithString:@"这是一段中文"],
                       [CellModel modelWithString:@""], nil];
        
        AMTextStyles *styles = [AMTextStyles defaultStyles];
        styles.highlightCodeOnRender = YES;
        [styles addStringAttributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0xe62c3b],
        }
                           forClass:@"up"];
        [styles addStringAttributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0xe62c3b],
        }
                           forClass:@"markdown-red-color"];
        [styles addStringAttributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0x0e9976],
        }
                           forClass:@"down"];
        [styles addStringAttributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0x0e9976],
        }
                           forClass:@"markdown-green-color"];
        [styles addStringAttributes:@{
            AMBackgroundDrawableAttributeName: [AMGradient gradientWithColors:@[
                [UIColor colorWithHex_ant_mark:0xfff2b3],
                [UIColor colorWithHex_ant_mark:0xfff2b3],
                [UIColor colorWithHex_ant_mark:0xfff2b3].transparentColor_ant_mark,
                [UIColor clearColor],
            ]
                                                                    locations:@[@0, @0.3, @0.5, @1]
                                                                       degree:0],
        }
                           forClass:@"highlight"];
        
        [styles registerTableBlockAttachmentBuilder:[AMBuilderBlock tableBuilder:^NSTextAttachment<AMViewAttachment> * _Nonnull(CMTable * _Nonnull table, AMTextStyles * _Nonnull styles) {
            AMTableViewAttachment *attach = [[AMTableViewAttachment alloc] initWithTable:table styles:styles];
            return attach;
        }]];
        self.styles = styles;
    }
    return self;
}

- (dispatch_queue_t)parsingQueue
{
    static dispatch_once_t onceToken;
    static dispatch_queue_t _queue;
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create("Markdown Parsing Queue", DISPATCH_QUEUE_SERIAL);
    });
    return _queue;
}

- (void)updateMarkdownPartially:(NSString *)markdown {
    CGFloat width = self.view.bounds.size.width - 40;
    if (self.cursor < markdown.length) {
        NSRange range = [markdown rangeOfComposedCharacterSequenceAtIndex:self.cursor];
        self.cursor += range.length + arc4random() % 10;
        dispatch_async([self parsingQueue], ^{
            NSString *sub = [markdown substringWithRange:NSMakeRange(0, NSMaxRange(range))];
            NSAttributedString *attr = [sub markdownToAttributedStringWithStyles_ant_mark:self.styles];
            CGRect rect = [attr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics
                                             context:nil];
            CellModel *model = self.models.lastObject;
            model.size = CGRectIntegral(rect).size;
            dispatch_async(dispatch_get_main_queue(), ^{
                [model.attributedText setAttributedString:attr];
                CFTimeInterval start = CACurrentMediaTime();
                MarkdownCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.models.count - 1
                                                                                               inSection:0]];
                [cell.textView setAttributedTextPartialUpdate_ant_mark:model.attributedText];
                [UIView performWithoutAnimation:^{
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
                    [self.tableView layoutIfNeeded];
                }];
                NSLog(@"Time use in partial update: %.3f", (CACurrentMediaTime() - start) * 1000);
                if (self.tableView.isDragging || self.tableView.isDecelerating) {
                    
                } else {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.models.count - 1
                                                                              inSection:0]
                                          atScrollPosition:UITableViewScrollPositionBottom
                                                  animated:NO];
                }
            });
        });
        [self performSelector:@selector(updateMarkdownPartially:) withObject:markdown afterDelay:0.04 inModes:@[NSRunLoopCommonModes]];
    } else {
        dispatch_async([self parsingQueue], ^{
            NSString *sub = markdown;
            NSAttributedString *attr = [sub markdownToAttributedStringWithStyles_ant_mark:self.styles];
            CGRect rect = [attr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics
                                             context:nil];
            CellModel *model = self.models.lastObject;
            model.size = CGRectIntegral(rect).size;
            dispatch_async(dispatch_get_main_queue(), ^{
                [model.attributedText setAttributedString:attr];
                CFTimeInterval start = CACurrentMediaTime();
                MarkdownCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.models.count - 1
                                                                                               inSection:0]];
                [cell.textView setAttributedTextPartialUpdate_ant_mark:model.attributedText];
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
                NSLog(@"Time use in partial update: %.3f", (CACurrentMediaTime() - start) * 1000);
                [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - 1, 1, 1)
                                           animated:NO];
            });
        });
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSError *error = nil;
    NSString *demo = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Sample" ofType:@"md"]
                                               encoding:NSUTF8StringEncoding
                                                  error:&error];
    
    self.cursor = 0;
    [self updateMarkdownPartially:demo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MarkdownCell *cell = (MarkdownCell *)[tableView dequeueReusableCellWithIdentifier:@"Markdown"
                                                                         forIndexPath:indexPath];
    CellModel *model = self.models[indexPath.row];
    cell.onSizeUpdate = ^(CGSize size) {
        model.size = size;
        [tableView beginUpdates];
        [tableView endUpdates];
    };
    [cell.textView setAttributedTextPartialUpdate_ant_mark:model.attributedText];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = self.models[indexPath.row].size;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return 80;
    }
    return size.height;
}

@end

@interface FootnoteBuilder : NSObject <AMFootnoteRefBuilder>

@end

@implementation FootnoteBuilder

- (NSAttributedString *)buildWithReference:(NSString *)reference title:(NSString *)title index:(NSInteger)index styles:(AMTextStyles *)styles
{
    return [[AMButtonViewAttachment alloc] initWithTitle:reference action:^{
        
    }].attributedString;
}

@end

@interface _StayBottomTextView : UITextView

@end

@implementation _StayBottomTextView

- (void)_tryScrollToBottom {
    [self layoutIfNeeded];
    [self scrollRectToVisible:CGRectMake(0, self.contentSize.height - 1, 1, 1) animated:YES];
}

- (void)setContentSize:(CGSize)contentSize
{
    CGSize oldSize = super.contentSize;
    if (!CGSizeEqualToSize(oldSize, contentSize)) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_tryScrollToBottom) object:nil];
        
        CGPoint offset = self.contentOffset;
        
        super.contentSize = contentSize;
        
        offset.y = contentSize.height - self.bounds.size.height + self.contentInset.bottom + self.adjustedContentInset.bottom;
        if (offset.y > 0) {
            if (!self.isDragging && !self.isDecelerating) {
                [self performSelector:@selector(_tryScrollToBottom) withObject:nil afterDelay:0.03];
            }
        }
    } else {
        super.contentSize = contentSize;
    }
}

@end

@interface AMViewController2 : UIViewController <UITextViewDelegate>
@property (nonatomic) IBOutlet UITextView *label;
@property (nonatomic) AMTextStyles *styles;
@property (nonatomic) NSInteger cursor;
@end

@implementation AMViewController2

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tabBarController.tabBar.backgroundColor = [UIColor clearColor];
    self.tabBarController.tabBar.backgroundImage = [UIImage new];
    self.tabBarController.tabBar.translucent = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.label removeFromSuperview];
    self.label = [[_StayBottomTextView alloc] initWithFrame_ant_mark:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(40, 0, 109, 0))];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textContainerInset = UIEdgeInsetsZero;
    self.label.textContainer.lineFragmentPadding = 20;
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.label.delegate = self;
    self.label.userInteractionEnabled = YES;
    //    self.label.selectable = YES;
    [self.view addSubview:self.label];
    
    NSError *error = nil;
    NSString *demo = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Demo" ofType:@"md"]
                                               encoding:NSUTF8StringEncoding
                                                  error:&error];
    
    AMTextStyles *styles = [AMTextStyles defaultStyles];
    styles.highlightCodeOnRender = YES;
    [styles addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0xe62c3b],
    }
                       forClass:@"up"];
    [styles addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0xe62c3b],
    }
                       forClass:@"markdown-red-color"];
    [styles addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0x0e9976],
    }
                       forClass:@"down"];
    [styles addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0x0e9976],
    }
                       forClass:@"markdown-green-color"];
    [styles addStringAttributes:@{
        AMBackgroundDrawableAttributeName: [AMGradient gradientWithColors:@[
            [UIColor colorWithHex_ant_mark:0xfff2b3],
            [UIColor colorWithHex_ant_mark:0xfff2b3],
            [UIColor colorWithHex_ant_mark:0xfff2b3].transparentColor_ant_mark,
            [UIColor clearColor],
        ]
                                                                locations:@[@0, @0.3, @0.5, @1]
                                                                   degree:0],
    }
                       forClass:@"highlight"];
    
    [styles registerTableBlockAttachmentBuilder:[AMBuilderBlock tableBuilder:^NSTextAttachment<AMViewAttachment> * _Nonnull(CMTable * _Nonnull table, AMTextStyles * _Nonnull styles) {
        AMTableViewAttachment *attach = [[AMTableViewAttachment alloc] initWithTable:table styles:styles];
        //        [(AMMarkdownTableView *)attach.view setTableOperationViews:@[
        //            ({
        //            UIView *v = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"gear"] target:nil action:nil];
        //            v;
        //        }),
        //            ({
        //            UIView *v = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"heart.fill"] target:nil action:nil];
        //            v;
        //        }),
        //        ]];
        return attach;
    }]];
    self.styles = styles;
    
    self.cursor = 0;
//    [self updateMarkdown:demo];
    [self updateMarkdownPartially:demo];
//    dispatch_async([self parsingQueue], ^{
//        NSString *sub = demo;
//        NSAttributedString *attr = [sub markdownToAttributedStringWithStyles_ant_mark:self.styles];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            CFTimeInterval start = CACurrentMediaTime();
//            [self.label setAttributedText_ant_mark:attr];
//            NSLog(@"Time use in full update: %.6f", CACurrentMediaTime() - start);
//        });
//    });
//    [self performSelectorInBackground:@selector(updateMarkdownPartially:) withObject:demo];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)updateMarkdown:(NSString *)markdown {
    CGFloat width = self.view.bounds.size.width - 40;
    if (self.cursor < markdown.length) {
        NSRange range = [markdown rangeOfComposedCharacterSequenceAtIndex:self.cursor];
        self.cursor += range.length + arc4random() % 10;
        dispatch_async([self parsingQueue], ^{
            NSString *sub = [markdown substringWithRange:NSMakeRange(0, NSMaxRange(range))];
            NSAttributedString *attr = [sub markdownToAttributedStringWithStyles_ant_mark:self.styles];
            CGRect rect = [attr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics
                                             context:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                CFTimeInterval start = CACurrentMediaTime();
                [self.label setAttributedText_ant_mark:attr];
                NSLog(@"Time use in full update: %.6f", CACurrentMediaTime() - start);
            });
        });
        [self performSelector:@selector(updateMarkdown:) withObject:markdown afterDelay:0.04 inModes:@[NSRunLoopCommonModes]];
    } else {
        dispatch_async([self parsingQueue], ^{
            NSString *sub = markdown;
            NSAttributedString *attr = [sub markdownToAttributedStringWithStyles_ant_mark:self.styles];
            dispatch_async(dispatch_get_main_queue(), ^{
                CFTimeInterval start = CACurrentMediaTime();
                [self.label setAttributedText_ant_mark:attr];
                NSLog(@"Time use in full update: %.6f", CACurrentMediaTime() - start);
            });
        });
    }
}

- (dispatch_queue_t)parsingQueue
{
    static dispatch_once_t onceToken;
    static dispatch_queue_t _queue;
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create("Markdown Parsing Queue", DISPATCH_QUEUE_SERIAL);
    });
    return _queue;
}

- (void)updateMarkdownPartially:(NSString *)markdown {
    CGFloat width = self.view.bounds.size.width - 40;
    if (self.cursor < markdown.length) {
        NSRange range = [markdown rangeOfComposedCharacterSequenceAtIndex:self.cursor];
        self.cursor += range.length + arc4random() % 10;
        dispatch_async([self parsingQueue], ^{
            NSString *sub = [markdown substringWithRange:NSMakeRange(0, NSMaxRange(range))];
            NSAttributedString *attr = [sub markdownToAttributedStringWithStyles_ant_mark:self.styles];
            CGRect rect = [attr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics
                                             context:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                CFTimeInterval start = CACurrentMediaTime();
                [self.label setAttributedTextPartialUpdate_ant_mark:attr];
                NSLog(@"Time use in partial update: %.6f", CACurrentMediaTime() - start);
            });
        });
        [self performSelector:@selector(updateMarkdownPartially:) withObject:markdown afterDelay:0.04 inModes:@[NSRunLoopCommonModes]];
    } else {
        dispatch_async([self parsingQueue], ^{
            NSString *sub = markdown;
            NSAttributedString *attr = [sub markdownToAttributedStringWithStyles_ant_mark:self.styles];
            dispatch_async(dispatch_get_main_queue(), ^{
                CFTimeInterval start = CACurrentMediaTime();
                [self.label setAttributedTextPartialUpdate_ant_mark:attr];
                NSLog(@"Time use in partial update: %.6f", CACurrentMediaTime() - start);
            });
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView
shouldInteractWithURL:(NSURL *)URL
         inRange:(NSRange)characterRange
     interaction:(UITextItemInteraction)interaction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"点击了链接"
                                                                   message:URL.absoluteString
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    return NO;
}

- (BOOL)textView:(UITextView *)textView
shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment
         inRange:(NSRange)characterRange
     interaction:(UITextItemInteraction)interaction
{
    return NO;
}

@end
