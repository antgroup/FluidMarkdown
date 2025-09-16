// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "NSString+AntMarkdown.h"
#import "AMTextStyles.h"
#import "AMAttributedStringRenderer.h"

const CMDocumentOptions AMDefaultDocumentOptions 
= CMDocumentOptionsNormalize | CMDocumentOptionsUnsafe | CMDocumentOptionsFootNotes
| CMDocumentOptionsFootNotesWithoutDefinition | CMDocumentOptionsStrikeThrough;

@implementation NSString (AntMarkdown)

- (NSAttributedString *)markdownToAttributedString_ant_mark
{
    return [self markdownToAttributedStringWithStyles_ant_mark:[AMTextStyles defaultStyles]];
}

- (NSAttributedString *)markdownToAttributedStringWithStyles_ant_mark:(AMTextStyles *)styles
{
    CMDocument *document = [[CMDocument alloc] initWithString:self options:AMDefaultDocumentOptions];
    
    AMAttributedStringRenderer *renderer = [[AMAttributedStringRenderer alloc] initWithDocument:document
                                                                                     attributes:styles];
    return renderer.render;
}
- (NSAttributedString *)markdownToAttributedStringWithStyles_ant_mark:(AMTextStyles *)styles delegate:(id<CMAttributedStringRendererDelegate>)delegate;
{
    CMDocument *document = [[CMDocument alloc] initWithString:self options:AMDefaultDocumentOptions];
    
    AMAttributedStringRenderer *renderer = [[AMAttributedStringRenderer alloc] initWithDocument:document
                                                                                     attributes:styles delegate:delegate];
    NSAttributedString* rst = renderer.render;
    [delegate notifyNodeUpdate:[renderer clickableObjs]];
    return rst;
}

@end
