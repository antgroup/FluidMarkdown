// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.


#import "AIChatViewController.h"
#import "AMXRenderService.h"
#import "AMXMarkdownTextView.h"

@interface AIChatViewController ()<AMXMarkdownTextViewDelegate, UITextFieldDelegate>
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) NSString* markdownStr;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) NSMutableArray* markdownViewArray;
@property (nonatomic, assign)int dataIndex;
@end

@implementation AIChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.markdownViewArray = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        NSString* fileName = [NSString stringWithFormat:@"data%d", (i + 1) ];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
                
        if (!filePath) {
            NSLog(@"not exist");
        } else {
            [self.dataArray addObject:[AIChatViewController readTextDataFromFile:filePath]];
        }
    }
    
    [self registerKeyboardNotifications];
    self.sendMessages = [NSMutableArray array];
    self.reciveMessages = [NSMutableArray array];
    
}
- (void)setMarkdown {
    
    [[AMXRenderService shared] setMarkdownStyleWithId:[AMXMarkdownStyleConfig defaultConfig] styleId:@"chat"];
    AMXMarkdownTextView* markdownView = [[AMXMarkdownTextView alloc] initWithFrame_ant_mark:CGRectMake(20, 0, self.view.frame.size.width - 80, 1) ];
    markdownView.styleId = @"chat";
    markdownView.textColor = [UIColor blackColor];
    markdownView.font = [UIFont systemFontOfSize:16];
    markdownView.textViewDelegate = self;
    [self.markdownViewArray addObject:markdownView];
    
    
}
- (void)setupUI {
    self.navigationItem.title = @"chat";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    self.inputView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.view addSubview:self.inputView];

    self.messageField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 80, 30)];
    self.messageField.borderStyle = UITextBorderStyleRoundedRect;
    self.messageField.delegate = self;
    [self.inputView addSubview:self.messageField];

    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.frame = CGRectMake(self.view.frame.size.width - 70, 10, 60, 30);
    [self.sendButton setTitle:@"send" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView addSubview:self.sendButton];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self forceOrientationPortrait];
}



- (void)forceOrientationPortrait {
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)sendMessage {
    if (self.messageField.text.length > 0) {
        [self.sendMessages addObject:@{@"text": self.messageField.text, @"isMe": @YES}];
        [self.tableView reloadData];
        [self totalContent];
        self.messageField.text = @"";

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setMarkdown];
            [self.reciveMessages addObject:[self.dataArray objectAtIndex:self.dataIndex]];
            self.markdownStr = [self.dataArray objectAtIndex:self.dataIndex];
            
            [self totalContent];
            [[self.markdownViewArray objectAtIndex:self.dataIndex] startStreamingWithContent:[self.dataArray objectAtIndex:self.dataIndex]];
            [self.tableView reloadData];
            self.dataIndex++;
            
        });
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    }
}

- (void)totalContent {
    self.total = self.sendMessages.count + self.reciveMessages.count;
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"";
    if (indexPath.row % 2 == 0) {
        cellIdentifier = @"sendMsgIdentifier";
    } else {
        // Markdown view will not be reused, if you want, you should control the data and state by yourself.
        cellIdentifier = [NSString stringWithFormat:@"%@%ld",@"reciveMsgIdentifier",indexPath.row];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row % 2 == 0) {
        // send
        NSDictionary *sendMessage = self.sendMessages[indexPath.row / 2];
        cell.textLabel.text = sendMessage[@"text"];
        cell.textLabel.numberOfLines = 0;
        
        if ([sendMessage[@"isMe"] boolValue]) {
            cell.textLabel.textAlignment = NSTextAlignmentRight;
            cell.textLabel.textColor = [UIColor blueColor];
            cell.textLabel.layoutMargins = UIEdgeInsetsMake(20, 0, 20, 0);
        }
    } else {
        // recive
        AMXMarkdownTextView* markdownView = [self.markdownViewArray objectAtIndex:(indexPath.row/ 2)];
        if (![markdownView superview]) {
            [cell.contentView addSubview:markdownView];
        }
        [cell setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, markdownView.frame.size.width, markdownView.frame.size.height)];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        // send
        NSDictionary *message = self.sendMessages[indexPath.row / 2];
        NSString *text = message[@"text"];
        
        CGSize size = [text boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 40, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                                         context:nil].size;
        return size.height + 20;
    } else {
        AMXMarkdownTextView* markdownView = [self.markdownViewArray objectAtIndex:(indexPath.row / 2)];
        return markdownView.frame.size.height;
    }
    
}

#pragma mark - Keyboard Handling

- (void)registerKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.keyboardHeight = keyboardSize.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.inputView.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height - keyboardSize.height;
        self.inputView.frame = frame;
        
        frame = self.tableView.frame;
        frame.size.height = self.view.frame.size.height - self.inputView.frame.size.height - keyboardSize.height;
        self.tableView.frame = frame;
    }];
    
    [self totalContent];
    if (self.dataIndex > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.dataIndex * 2 - 1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.inputView.frame;
        frame.origin.y = self.view.frame.size.height - frame.size.height;
        self.inputView.frame = frame;
        
        frame = self.tableView.frame;
        frame.size.height = self.view.frame.size.height - self.inputView.frame.size.height;
        self.tableView.frame = frame;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessage];
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didChangeState:(AMXMarkdownPrintState)state {

}

- (void)onError:(nonnull NSError *)error {
    
}

- (void)onSizeChange:(CGSize)size {
    AMXMarkdownTextView* markdownView = [self.markdownViewArray objectAtIndex:(self.dataIndex - 1)];
    [markdownView setFrame:CGRectMake(20, 0, markdownView.frame.size.width, size.height)];
    [markdownView.superview setFrame:CGRectMake(markdownView.superview.frame.origin.x, markdownView.superview.frame.origin.y, size.width, size.height)];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.dataIndex * 2 - 1) inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)onTap:(AMXMarkdownTapType)type content:(nonnull id)content gesture:(nonnull UITapGestureRecognizer *)gesture attachment:(nonnull NSTextAttachment *)attachment tapIndex:(NSUInteger)tapIndex attrString:(nonnull NSAttributedString *)attrString {
    
}

- (void)onUpdateExposureElement:(nonnull NSArray<AMXMarkdownCustomRenderEventModel *> *)elements {
    
}

+ (NSString *)readTextDataFromFile:(NSString *)filePath {
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    
    if (error) {
        NSLog(@"read file error: %@", error.localizedDescription);
        return nil;
    }
    NSMutableArray *textLines = [[NSMutableArray alloc] init];
    [textLines addObject:fileContents];
    return fileContents;
}
@end

