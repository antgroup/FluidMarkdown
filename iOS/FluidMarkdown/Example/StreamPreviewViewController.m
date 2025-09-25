// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "StreamPreviewViewController.h"
#import "ToastView.h"
CGFloat buttonHeight = 40;
@implementation CustomButton {
    CAGradientLayer *_gradientLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
                   title:(NSString *)title
              titleColor:(UIColor *)titleColor
           gradientStart:(UIColor *)startColor
             gradientEnd:(UIColor *)endColor {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        
        _cornerRadius = 12.0;
        _shadowOffset = CGSizeMake(0, 4);
        _shadowOpacity = 0.2;
        _shadowColor = [UIColor blackColor];
        
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
        _gradientLayer.startPoint = CGPointMake(0, 0.5);
        _gradientLayer.endPoint = CGPointMake(1, 0.5);
        [self.layer insertSublayer:_gradientLayer atIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradientLayer.frame = self.bounds;
    _gradientLayer.cornerRadius = _cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

@end

@interface StreamPreviewViewController ()<AMXMarkdownTextViewDelegate, UITextFieldDelegate>
@property(nonatomic, assign)NSInteger printState;
@property(nonatomic, assign)BOOL isFinish;
@end

@implementation StreamPreviewViewController
-(void)initUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat screenWidht = [UIScreen mainScreen].bounds.size.width;
    CGFloat buttonWidth = (screenWidht - 20 * 4)/3;
    
    self.actionStartButton = [[CustomButton alloc]
                              initWithFrame:CGRectMake(20, 50 + self.navigationController.navigationBar.frame.size.height, buttonWidth, buttonHeight)
                         title:@"start print"
                         titleColor:[UIColor whiteColor]
                         gradientStart:[UIColor colorWithRed:0.10 green:0.68 blue:1.00 alpha:1.0]
                         gradientEnd:[UIColor colorWithRed:0.20 green:0.40 blue:0.95 alpha:1.0]];

    self.actionStartButton.cornerRadius = 10;
    self.actionStartButton.shadowOffset = CGSizeMake(0, 6);
    self.actionStartButton.shadowOpacity = 0.3;
    self.actionStartButton.backgroundColor = [UIColor lightGrayColor];
    [self.actionStartButton addTarget:self action:@selector(buttonTappedStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionStartButton];

    
    self.actionPauseButton = [[CustomButton alloc]
                              initWithFrame:CGRectMake(self.actionStartButton.frame.origin.x + buttonWidth + 20, 50 + self.navigationController.navigationBar.frame.size.height, buttonWidth, buttonHeight)
                         title:@"pause"
                         titleColor:[UIColor whiteColor]
                         gradientStart:[UIColor colorWithRed:0.10 green:0.68 blue:1.00 alpha:1.0]
                         gradientEnd:[UIColor colorWithRed:0.20 green:0.40 blue:0.95 alpha:1.0]];

    self.actionPauseButton.cornerRadius = 10;
    self.actionPauseButton.shadowOffset = CGSizeMake(0, 6);
    self.actionPauseButton.shadowOpacity = 0.3;
    self.actionPauseButton.backgroundColor = [UIColor lightGrayColor];
    [self.actionPauseButton addTarget:self action:@selector(buttonTappedPause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionPauseButton];
    
    self.actionResumeButton = [[CustomButton alloc]
                               initWithFrame:CGRectMake(self.actionPauseButton.frame.origin.x + buttonWidth + 20, 50 + self.navigationController.navigationBar.frame.size.height, buttonWidth, buttonHeight)
                         title:@"continue"
                         titleColor:[UIColor whiteColor]
                         gradientStart:[UIColor colorWithRed:0.10 green:0.68 blue:1.00 alpha:1.0]
                         gradientEnd:[UIColor colorWithRed:0.20 green:0.40 blue:0.95 alpha:1.0]];

    self.actionResumeButton.cornerRadius = 10;
    self.actionResumeButton.shadowOffset = CGSizeMake(0, 6);
    self.actionResumeButton.shadowOpacity = 0.3;
    self.actionResumeButton.backgroundColor = [UIColor lightGrayColor];
    [self.actionResumeButton addTarget:self action:@selector(buttonTappedResume) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionResumeButton];
    
    self.actionStopButton = [[CustomButton alloc]
                             initWithFrame:CGRectMake(20, self.actionStartButton.frame.origin.y + buttonHeight + 20, buttonWidth, buttonHeight)
                         title:@"stop"
                         titleColor:[UIColor whiteColor]
                         gradientStart:[UIColor colorWithRed:0.10 green:0.68 blue:1.00 alpha:1.0]
                         gradientEnd:[UIColor colorWithRed:0.20 green:0.40 blue:0.95 alpha:1.0]];

    self.actionStopButton.cornerRadius = 10;
    self.actionStopButton.shadowOffset = CGSizeMake(0, 6);
    self.actionStopButton.shadowOpacity = 0.3;
    self.actionStopButton.backgroundColor = [UIColor lightGrayColor];
    [self.actionStopButton addTarget:self action:@selector(buttonTappedStop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionStopButton];
    
    self.actionAppendButton = [[CustomButton alloc]
                               initWithFrame:CGRectMake(self.actionStopButton.frame.origin.x + buttonWidth + 20, self.actionStartButton.frame.origin.y + buttonHeight + 20, buttonWidth, buttonHeight)
                         title:@"append"
                         titleColor:[UIColor whiteColor]
                         gradientStart:[UIColor colorWithRed:0.10 green:0.68 blue:1.00 alpha:1.0]
                         gradientEnd:[UIColor colorWithRed:0.20 green:0.40 blue:0.95 alpha:1.0]];

    self.actionAppendButton.cornerRadius = 10;
    self.actionAppendButton.shadowOffset = CGSizeMake(0, 6);
    self.actionAppendButton.shadowOpacity = 0.3;
    self.actionAppendButton.backgroundColor = [UIColor lightGrayColor];
    [self.actionAppendButton addTarget:self action:@selector(buttonTappedAppend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionAppendButton];
    
    self.oneceButton = [[CustomButton alloc]
                               initWithFrame:CGRectMake(self.actionAppendButton.frame.origin.x + buttonWidth + 20, self.actionStartButton.frame.origin.y + buttonHeight + 20, buttonWidth, buttonHeight)
                         title:@"onece render"
                         titleColor:[UIColor whiteColor]
                         gradientStart:[UIColor colorWithRed:0.10 green:0.68 blue:1.00 alpha:1.0]
                         gradientEnd:[UIColor colorWithRed:0.20 green:0.40 blue:0.95 alpha:1.0]];

    self.oneceButton.cornerRadius = 10;
    self.oneceButton.shadowOffset = CGSizeMake(0, 6);
    self.oneceButton.shadowOpacity = 0.3;
    self.oneceButton.backgroundColor = [UIColor lightGrayColor];
    [self.oneceButton addTarget:self action:@selector(buttonTappedOnce) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.oneceButton];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initStyle];
    
    CGFloat screenWidht = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    [self initUI];
    
    
    self.inputView = [[UITextView alloc] init];
    self.inputView.font = [UIFont systemFontOfSize:16.0];
    self.inputView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.inputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.inputView.layer.borderWidth = 0.5;
    self.inputView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputView.scrollEnabled = YES;
    self.inputView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.inputView.delegate = self;
    [self.inputView setFrame:CGRectMake(20, self.oneceButton.frame.origin.y + self.oneceButton.frame.size.height + 20 , screenWidht - 20 * 2, 200)];
    [self.view addSubview:self.inputView];
    
    self.containerView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, self.inputView.frame.origin.y + self.inputView.frame.size.height + 20, screenWidht - 20 * 2, screenHeight - (self.inputView.frame.origin.y + self.inputView.frame.size.height + 20 + 40))];

    self.contentTextView = [[AMXMarkdownTextView alloc] initWithFrame_ant_mark:CGRectMake(0, 0, screenWidht - 20 * 2, 1)];
    self.contentTextView.styleId = @"demo";
    self.contentTextView.textColor = [UIColor blackColor];
    self.contentTextView.font = [UIFont systemFontOfSize:16];
    self.contentTextView.textViewDelegate = self;
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.contentTextView];
}
-(void)initStyle
{
    [[AMXRenderService shared] setMarkdownStyleWithId:[AMXMarkdownStyleConfig defaultConfig] styleId:@"demo"];
}
- (void)buttonTappedStart {
    [UIView animateWithDuration:0.1 animations:^{
        self.actionStartButton.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.actionStartButton.transform = CGAffineTransformIdentity;
        }];
    }];
    [self.contentTextView startStreamingWithContent:_inputView.text];

    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
- (void)buttonTappedPause {
    [UIView animateWithDuration:0.1 animations:^{
        self.actionPauseButton.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.actionPauseButton.transform = CGAffineTransformIdentity;
        }];
    }];
    [self.contentTextView pause];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
- (void)buttonTappedResume {
    [UIView animateWithDuration:0.1 animations:^{
        self.actionResumeButton.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.actionResumeButton.transform = CGAffineTransformIdentity;
        }];
    }];
    [ToastView showToastInView:self.view withText:@"continue" duration:2.0];
    [self.contentTextView resume];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
- (void)buttonTappedStop {
    [UIView animateWithDuration:0.1 animations:^{
        self.actionStopButton.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.actionStopButton.transform = CGAffineTransformIdentity;
        }];
    }];
    [self.contentTextView stop];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
- (void)buttonTappedAppend {
    [UIView animateWithDuration:0.1 animations:^{
        self.actionAppendButton.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.actionAppendButton.transform = CGAffineTransformIdentity;
        }];
    }];
    [ToastView showToastInView:self.view withText:@"append string：**潇珺测试内容**" duration:2.0];
    [self.contentTextView addStreamContent:@"**潇珺测试内容**"];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
-(void)buttonTappedOnce {
    [UIView animateWithDuration:0.1 animations:^{
        self.oneceButton.transform = CGAffineTransformMakeScale(0.95, 0.95);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.oneceButton.transform = CGAffineTransformIdentity;
        }];
    }];
    [self.contentTextView renderCompleteContent:_inputView.text];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
-(void)onSizeChange:(CGSize)size
{
    [self.contentTextView setFrame:CGRectMake(0, 0, self.contentTextView.frame.size.width, size.height)];
    [self.containerView setContentSize:size];
    CGPoint bottomOffset = CGPointMake(0, self.containerView.contentSize.height - self.containerView.bounds.size.height);
    if (bottomOffset.y > 0) {
        [self.containerView setContentOffset:bottomOffset animated:NO];
    }
}
-(void)onError:(NSError*)error {
    NSLog(@"");
}
-(void)didChangeState:(AMXMarkdownPrintState)state
{
    if (state == AMXMarkdownPrintStateStopped) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGPoint bottomOffset = CGPointMake(0, self.containerView.contentSize.height - self.containerView.bounds.size.height);
            if (bottomOffset.y > 0) {
                [self.containerView setContentOffset:bottomOffset animated:NO];
            }
            [ToastView showToastInView:self.view withText:@"stop" duration:2.0];
            self.printState = 0;
            self.isFinish = YES;
        });
    }
    if (state == AMXMarkdownPrintStatePaused) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ToastView showToastInView:self.view withText:@"pause" duration:2.0];
        });
    }
}
-(void)start
{
    [ToastView showToastInView:self.view withText:@"start" duration:2.0];
    NSString* contentStr = [self markdownReplaceBr:self.inputView.text];
    [self.contentTextView startStreamingWithContent:contentStr];
}
-(void)stop
{
    [self.contentTextView stop];
}
-(void)continuePrint
{
    [self.contentTextView resume];
}
- (NSString*)markdownReplaceBr:(NSString *)markdown {
    if(!(markdown && [markdown isKindOfClass:[NSString class]] && ![@"" isEqualToString:markdown]))
        return markdown;
        
    NSString* resStr = [markdown stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    
    NSString *pattern = @"\\\\\\[([\\s\\S]*?)\\\\\\]";
    
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    if (error) {
        return resStr;
    }
    
    NSString *replacementString = @"$$$1$$";
    NSString *resultString = [regex stringByReplacingMatchesInString:resStr options:0 range:NSMakeRange(0, resStr.length) withTemplate:replacementString];
    
    
    NSString *pattern2 = @"\\\\\\((.*?)\\\\\\)";

    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:pattern2 options:0 error:&error];
    
    if (error) {
        NSLog(@"regular exception: %@", error.localizedDescription);
        return resultString;
    }
    
    NSString *replacementString2 = @"$$1$";
    NSString *resultString2 = [regex2 stringByReplacingMatchesInString:resultString options:0 range:NSMakeRange(0, resultString.length) withTemplate:replacementString2];
    
    return resultString2;
}
-(void)onUpdateExposureElement:(NSArray<AMXMarkdownCustomRenderEventModel*>*)elements
{
    NSLog(@"onUpdateExposureElement %ld", elements.count);
}
-(void)onTap:(AMXMarkdownTapType)type content:(id)content gesture:(UITapGestureRecognizer *)gesture attachment:(NSTextAttachment*)attachment tapIndex:(NSUInteger)tapIndex attrString:(NSAttributedString*)attrString
{
   
}
@end
