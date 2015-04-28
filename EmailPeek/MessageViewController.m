/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "MessageViewController.h"

#import "NSDate+Office365.h"
#import "Message.h"
#import "MessageDetail.h"
#import "ConversationManager.h"

static NSString * const kWebViewContentSizeKeyPath = @"scrollView.contentSize";
static NSString * const kHideMessageButtonTitle    = @"Hide";
static NSString * const kUnhideMessageButtonTitle  = @"Unhide";

@interface MessageViewController () <UIWebViewDelegate>

@property (strong,   nonatomic) MessageDetail *messageDetail;
@property (readonly, nonatomic) BOOL           isFollowingSender;
@property (readonly, nonatomic) BOOL           isFollowingConversation;

@property (weak, nonatomic) IBOutlet UILabel                 *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel                 *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel                 *dateReceivedLabel;
@property (weak, nonatomic) IBOutlet UILabel                 *toLabel;
@property (weak, nonatomic) IBOutlet UILabel                 *ccLabel;
@property (weak, nonatomic) IBOutlet UILabel                 *attachmentsLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem         *followBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem         *hideBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem         *replyBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem         *replyAllBarButtonItem;

@property (weak, nonatomic) IBOutlet UIWebView               *bodyWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint      *bodyWebViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MessageViewController

#pragma mark - Properties
- (void)setMessage:(Message *)message
{
    _message = message;

    if (self.isViewLoaded) {
        [self fetchMessageDetailForMessage:message];
        [self updateMessageUI];
        [self updateFollowBarButtonItem];
    }
}

- (void)setMessageDetail:(MessageDetail *)messageDetail
{
    if (messageDetail && ![messageDetail.guid isEqualToString:self.message.guid]) {
        NSLog(@"ERROR: Attempting to set a message detail that does not match the active message.");
        return;
    }

    _messageDetail = messageDetail;

    [self markMessageAsRead:self.message];
    [self updateMessageDetailUI];
}

- (BOOL)isFollowingSender
{
    return [self.delegate messageViewController:self
                    isFollowingSenderForMessage:self.message];
}

- (BOOL)isFollowingConversation
{
    return [self.delegate messageViewController:self
              isFollowingConversationForMessage:self.message];
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.splitViewController) {
        self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        self.navigationItem.leftItemsSupplementBackButton = YES;
    }

    self.bodyWebView.scrollView.scrollEnabled = NO;

    // Get notified every time the contentSize of the webview changes;
    [self.bodyWebView addObserver:self
                       forKeyPath:kWebViewContentSizeKeyPath
                          options:0
                          context:NULL];

    if (self.message) {
        [self fetchMessageDetailForMessage:self.message];
        [self updateMessageUI];
    }

    [self updateUI];
}

- (void)dealloc
{
    [self.bodyWebView removeObserver:self
                          forKeyPath:kWebViewContentSizeKeyPath];
}


#pragma mark - UI Setup/Update
- (void)updateUI
{
    [self updateMessageUI];
    [self updateMessageDetailUI];
    [self updateFollowBarButtonItem];
}

- (void)updateMessageUI
{
    self.subjectLabel.text       = self.message.subject;
    self.senderLabel.text        = [self.message.sender description];
    self.dateReceivedLabel.text  = [self.message.dateReceived o365_mediumString];
    self.toLabel.text            = [self.message.toRecipients componentsJoinedByString:@", "];
    self.ccLabel.text            = [self.message.ccRecipients componentsJoinedByString:@", "];
    self.hideBarButtonItem.title = self.message.isHidden ? kUnhideMessageButtonTitle : kHideMessageButtonTitle;

    if (self.message) {
        self.attachmentsLabel.text   = self.message.hasAttachments ? @"Yes" : @"None";
    }
    else {
        self.attachmentsLabel.text = nil;
    }

    NSUInteger recipientCount = self.message.toRecipients.count + self.message.ccRecipients.count;
    self.replyAllBarButtonItem.enabled = (recipientCount > 1);
    self.replyBarButtonItem.enabled    = (self.message != nil);
    self.hideBarButtonItem.enabled     = (self.message != nil);
    self.followBarButtonItem.enabled   = (self.message != nil);
}

- (void)updateMessageDetailUI
{
    if (self.messageDetail.attachments.count > 0) {
        NSString *attachmentNames = [self.messageDetail.attachments componentsJoinedByString:@", "];

        self.attachmentsLabel.text = [NSString stringWithFormat:@"(%lu) %@", (unsigned long)self.messageDetail.attachments.count, attachmentNames];
    }

    NSString *messageBody = self.messageDetail.body;

    if (self.messageDetail.body && !self.messageDetail.isBodyHTML) {
        // Let's do some basic conversion to HTML
        NSMutableString *textMessageBody = [NSMutableString stringWithString:self.messageDetail.body];

        [textMessageBody replaceOccurrencesOfString:@"\n"
                                         withString:@"<br/>"
                                            options:0
                                              range:NSMakeRange(0, textMessageBody.length)];

        [textMessageBody replaceOccurrencesOfString:@"\t"
                                         withString:@"    "
                                            options:0
                                              range:NSMakeRange(0, textMessageBody.length)];

        [textMessageBody replaceOccurrencesOfString:@"  "
                                         withString:@" &nbsp;"
                                            options:0
                                              range:NSMakeRange(0, textMessageBody.length)];

        messageBody = textMessageBody;
    }

    [self.bodyWebView loadHTMLString:messageBody
                             baseURL:nil];
}

- (void)updateFollowBarButtonItem
{
    NSString   *followPrefix;
    NSUInteger  followCount = 0;

    if (self.isFollowingSender)       { followCount++; }
    if (self.isFollowingConversation) { followCount++; }

    switch (followCount) {
        case 0:
            followPrefix = @"+";
            break;
        case 1:
            followPrefix = @"±";
            break;
        case 2:
            followPrefix = @"-";
            break;
    }

    NSString        *newFollowTitle         = [NSString stringWithFormat:@"%@ Follow", followPrefix];
    UIBarButtonItem *newFollowBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:newFollowTitle
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(followTapped:)];
    newFollowBarButtonItem.enabled = self.followBarButtonItem.enabled;

    self.navigationItem.rightBarButtonItem = newFollowBarButtonItem;
    self.followBarButtonItem               = newFollowBarButtonItem;
}


#pragma mark - Actions
- (IBAction)followTapped:(UIBarButtonItem *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"What would you like to follow?"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    alertController.popoverPresentationController.barButtonItem = sender;

    UIAlertAction *senderAction;
    UIAlertAction *conversationAction;

    if (self.isFollowingSender) {
        senderAction = [UIAlertAction actionWithTitle:@"Unfollow Sender"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action) {
                                                  [self.delegate messageViewController:self
                                                                    shouldFollowSender:NO
                                                                            forMessage:self.message];
                                                  [self updateFollowBarButtonItem];
                                              }];
    }
    else {
        senderAction = [UIAlertAction actionWithTitle:@"Follow Sender"
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action) {
                                                  [self.delegate messageViewController:self
                                                                    shouldFollowSender:YES
                                                                            forMessage:self.message];
                                                  [self updateFollowBarButtonItem];
                                              }];
    }

    if (self.isFollowingConversation) {
        conversationAction = [UIAlertAction actionWithTitle:@"Unfollow Conversation"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [self.delegate messageViewController:self
                                                                    shouldFollowConversation:NO
                                                                                  forMessage:self.message];

                                                        [self updateFollowBarButtonItem];
                                                    }];
    }
    else {
        conversationAction = [UIAlertAction actionWithTitle:@"Follow Conversation"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [self.delegate messageViewController:self
                                                                    shouldFollowConversation:YES
                                                                                  forMessage:self.message];

                                                        [self updateFollowBarButtonItem];
                                                    }];
    }

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:NULL];

    [alertController addAction:senderAction];
    [alertController addAction:conversationAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:NULL];
}

- (IBAction)hideTapped:(UIBarButtonItem *)sender
{
    BOOL      hideMessage = [sender.title isEqualToString:kHideMessageButtonTitle];
    NSString *newTitle    = hideMessage ? kUnhideMessageButtonTitle : kHideMessageButtonTitle;

    [self.conversationManager markMessage:self.message
                                 isHidden:hideMessage
                        completionHandler:^(Message *updatedMessage, NSError *error) {
                            self.message = updatedMessage;
                        }];

    sender.title = newTitle;
}

- (IBAction)replyTapped:(id)sender
{
    [self replyToMessage:NO
       fromBarButtonItem:sender];
}

- (IBAction)replyAllTapped:(id)sender
{
    [self replyToMessage:YES
     fromBarButtonItem:sender];
}


#pragma mark - Message Detail Operations
- (void)fetchMessageDetailForMessage:(Message *)message
{
    if ([message.guid isEqualToString:self.messageDetail.guid]) {
        return;
    }

    [self.activityIndicator startAnimating];

    [self.conversationManager messageDetailForMessage:message
                                    completionHandler:^(MessageDetail *messageDetail, NSError *error) {
                                        if (!messageDetail) {
                                            NSLog(@"ERROR: Had trouble fetching the message {%@}", [error localizedDescription]);
                                        }

                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.activityIndicator stopAnimating];
                                            self.messageDetail = messageDetail;
                                        });
                                    }];
}

- (void)markMessageAsRead:(Message *)message
{
    [self.conversationManager markMessage:message
                                   isRead:YES];
}

- (void)   replyToMessage:(BOOL)replyAll
        fromBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSString          *alertTitle      = replyAll ? @"Reply to All" : @"Reply to Sender";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:@"Choose a message to send."
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];



    alertController.popoverPresentationController.barButtonItem = barButtonItem;

    // Can accommodate a variable number of quick responses
    for (NSString *responseBody in self.conversationManager.quickResponseBodies) {
        UIAlertAction *replyAction = [UIAlertAction actionWithTitle:responseBody
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                [self.delegate messageViewController:self
                                                                                      shouldReplyAll:replyAll
                                                                                           toMessage:self.message
                                                                                        withResponse:responseBody];
                                                            }];

        [alertController addAction:replyAction];
    }

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:NULL];

    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:NULL];
}


#pragma mark - UIWebViewDelegate
- (BOOL)                   webView:(UIWebView *)webView
        shouldStartLoadWithRequest:(NSURLRequest *)request
                    navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType != UIWebViewNavigationTypeLinkClicked) {
        return YES;
    }

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Open URL"
                                                                             message:@"Are you sure you want to leave the app?"
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:NULL];

    UIAlertAction *okAction     = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self.conversationManager.application openURL:request.URL];
                                                         }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:NULL];

    return NO;
}


#pragma mark - Key Value Observing
// This will be called when the contentSize of the webView changes.  Here,
// we will update the height of the webView so that it is as large as it needs
// to be to accommodate all of its content.  This makes it so the webView will
// not scroll, but its container scrollView WILL scroll.  It allows the
// "header information" and the "message body" to scroll as one unit.
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:kWebViewContentSizeKeyPath]) {
        CGSize newContentSize = self.bodyWebView.scrollView.contentSize;

        self.bodyWebViewHeightConstraint.constant = newContentSize.height;
    }
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
