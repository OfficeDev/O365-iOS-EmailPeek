/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "MessagePreviewCell.h"

#import "UIColor+Office365.h"
#import "NSDate+Office365.h"
#import "Message.h"
#import "Conversation.h"

const UILayoutPriority kEnableConstraintPriority  = 950;
const UILayoutPriority kDisableConstraintPriority = 850;

@interface MessagePreviewCell ()

@property (weak, nonatomic) IBOutlet UIView  *messageStateView;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyPreviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateReceivedLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageCountLabel;
@property (weak, nonatomic) IBOutlet UIView  *messageCountBackgroundView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageCountBackgroundViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *importanceLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attachmentsLabelWidthConstraint;

@end

@implementation MessagePreviewCell

#pragma mark - Lifecycle
- (void)awakeFromNib
{
    [super awakeFromNib];

    [self setupUI];
}


#pragma mark - Properties
- (void)setMessagePreview:(id<MessagePreview>)messagePreview
{
    _messagePreview = messagePreview;

    [self updateUI];
}


#pragma mark - UI Setup/Update
- (void)setupUI
{
    self.preservesSuperviewLayoutMargins                = NO;

    self.selectedBackgroundView                         = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor         = [UIColor o365_primaryHighlightColor];

    self.messageCountBackgroundView.layer.cornerRadius  = CGRectGetHeight(self.messageCountBackgroundView.bounds) / 2.0;
    self.messageCountBackgroundView.layer.masksToBounds = YES;
    self.messageCountBackgroundView.backgroundColor     = [UIColor o365_primaryColor];    
}

-(void)updateUI
{
    self.subjectLabel.text                = self.messagePreview.subject;
    self.senderLabel.text                 = self.messagePreview.sender.name;
    self.dateReceivedLabel.text           = [self.messagePreview.dateReceived o365_relativeString];
    self.bodyPreviewLabel.text            = self.messagePreview.bodyPreview;
    self.messageCountLabel.text           = [NSString stringWithFormat:@"%lu", (unsigned long)self.messagePreview.messageCount];
    self.messageStateView.backgroundColor = [self stateViewColor];

    // These aspects are either shown or hidden
    self.attachmentsLabelWidthConstraint.priority           = self.messagePreview.hasAttachments                      ? kEnableConstraintPriority : kDisableConstraintPriority;
    self.importanceLabelWidthConstraint.priority            = self.messagePreview.importance == MessageImportanceHigh ? kEnableConstraintPriority : kDisableConstraintPriority;
    self.messageCountBackgroundViewWidthConstraint.priority = self.messagePreview.messageCount > 1                    ? kEnableConstraintPriority : kDisableConstraintPriority;
}

- (UIColor *)stateViewColor
{
    if (self.highlighted || self.selected) { return [UIColor o365_primaryColor];       }
    if (!self.messagePreview.isRead)       { return [UIColor o365_unreadMessageColor]; }

    return [UIColor o365_defaultMessageColor];
}

- (void)setHighlighted:(BOOL)highlighted
              animated:(BOOL)animated
{
    [super setHighlighted:highlighted
                 animated:animated];

    [self updateBackgroundColors];
}

- (void)setSelected:(BOOL)selected
           animated:(BOOL)animated
{
    [super setSelected:selected
              animated:animated];

    [self updateBackgroundColors];
}

- (void)updateBackgroundColors
{
    // NOTE: If we don't explicitly set this color again, it will be set to
    //       transparent by default
    self.messageCountBackgroundView.backgroundColor = [UIColor o365_primaryColor];
    self.messageStateView.backgroundColor           = [self stateViewColor];
}

@end

// *********************************************************
//
// O365-iOS-EmailPeek, https://github.com/OfficeDev/O365-iOS-EmailPeek
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// *********************************************************
