// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMTableViewAttachment.h"
#import "AMMarkdownTableView.h"
#import "AMTextStyles.h"

@implementation AMTableViewAttachment
{
    UIView<AMTableView> * _tableView;
}

+ (Class)tableViewClass
{
    return [AMMarkdownTableView class];
}

- (instancetype)initWithTable:(nonnull CMTable *)table styles:(nonnull AMTextStyles *)styles {
    self = [super init];
    if (self) {
        self.table = table;
        _styles = styles;
    }
    return self;
}

- (UIView<AMTableView> *)view {
    if (!_tableView) {
        Class cls = [self.class tableViewClass];
        if ([cls instancesRespondToSelector:@selector(initWithStyles:)]) {
            _tableView = [[cls alloc] initWithStyles:_styles ?: [AMTextStyles defaultStyles]];
        } else {
            _tableView = [[cls alloc] initWithFrame:CGRectZero];
        }
        NSAssert([_tableView conformsToProtocol:@protocol(AMTableView)], @"Class %@ must confirms to AMTableView", cls);
        _tableView.table = self.table;
    }
    return _tableView;
}

- (__kindof UIView<AMAttachedView> *)viewIfLoaded
{
    return _tableView;
}

- (void)setTable:(CMTable *)table
{
    _table = table;
    _tableView.table = table;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if ([NSThread isMainThread] && [self viewIfLoaded]) {
        return [self.view sizeThatFits:size];
    } else {
        Class cls = [self.class tableViewClass];
        if ([cls respondsToSelector:@selector(sizeThatFits:table:styles:)]) {
            return [cls sizeThatFits:size table:self.table styles:_styles];
        } else {
            return [self.view sizeThatFits:size];
        }
    }
}

- (BOOL)isEqualToAttachment:(AMTableViewAttachment *)attach
{
    return [self.styles isEqual:attach.styles] && [self.table isEqual:attach.table];
}

- (void)updateAttachmentFromAttachment:(AMTableViewAttachment *)attach
{
    [super updateAttachmentFromAttachment:attach];
    self.partialUpdate = YES;
    if ([_tableView isKindOfClass:[AMMarkdownTableView class]]) {
        ((AMMarkdownTableView *)_tableView).partialUpdate = self.partialUpdate;
    }
    self.table = attach.table;
}
- (NSAttributedString *)attributedString {
    NSMutableAttributedString *attr = [[NSAttributedString attributedStringWithAttachment:self] mutableCopy];
    if (self.fullWidth) {
        NSParagraphStyle *paragraph = ({
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.paragraphSpacing = _styles.tableAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing] ?  [_styles.tableAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing] floatValue] : 0;
            style.paragraphSpacingBefore = _styles.tableAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore] ?  [_styles.tableAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore] floatValue] : 10;
            style.lineSpacing = 0;
            style.lineHeightMultiple = 1;
            style.lineBreakStrategy = NSLineBreakStrategyPushOut;
            style.firstLineHeadIndent = 0;
            style;
        });
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [attr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attr.length)];
    }
    return [attr copy];
}
@end
