/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "ConversationViewController.h"
#import "MessageViewController.h"
#import "Conversation.h"
#import "MessagePreview.h"
#import "Message.h"
#import "MessagePreviewCell.h"
#import "ConversationManager.h"


static NSString * const CellIdentifier = @"MessagePreviewCell";

@interface ConversationViewController ()

@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation ConversationViewController

#pragma mark - Properties
- (void)setConversationManager:(ConversationManager *)conversationManager
{
    // Remove the existing notification registrations
    NSNotificationCenter *notificationCenter = _conversationManager.notificationCenter;

    [notificationCenter removeObserver:self
                                  name:nil
                                object:_conversationManager];

    _conversationManager = conversationManager;

    notificationCenter = _conversationManager.notificationCenter;

    [notificationCenter addObserver:self
                           selector:@selector(allConversationsDidChange:)
                               name:ConversationManagerAllConversationsDidChangeNotification
                             object:_conversationManager];
}

- (void)setConversation:(Conversation *)conversation
{
    _conversation = conversation;

    NSArray *ascendingList  = [conversation.messages sortedArrayUsingSelector:@selector(compare:)];
    NSArray *descendingList = [[ascendingList reverseObjectEnumerator] allObjects];

    self.messages = [descendingList mutableCopy];

    [self.tableView reloadData];
}


#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.layoutMargins = UIEdgeInsetsZero;
    
    UINib *cellNib = [UINib nibWithNibName:CellIdentifier
                                    bundle:nil];

    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:CellIdentifier];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMessage"]) {
        NSIndexPath  *selectedIndexPath    = [self.tableView indexPathForCell:sender];
        Message      *selectedMessage      = self.messages[selectedIndexPath.row];

        UINavigationController *navigationVC = segue.destinationViewController;
        MessageViewController  *messageVC    = navigationVC.viewControllers[0];

        messageVC.conversationManager = self.conversationManager;
        messageVC.message             = selectedMessage;
        messageVC.delegate            = self.delegate;
    }
}

- (void)dealloc
{
    NSNotificationCenter *notificationCenter = _conversationManager.notificationCenter;

    [notificationCenter removeObserver:self
                                  name:nil
                                object:_conversationManager];
}


#pragma mark - UITableViewDataSource
- (NSInteger)            tableView:(UITableView *)tableView
             numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)            tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message            *message = self.messages[indexPath.row];
    MessagePreviewCell *cell    = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                  forIndexPath:indexPath];

    cell.messagePreview = message;

    return cell;
}

- (BOOL)            tableView:(UITableView *)tableView
        canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)         tableView:(UITableView *)tableView
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
         forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    Message *message = self.messages[indexPath.row];

    [self.conversationManager markMessage:message
                                 isHidden:YES
                        completionHandler:NULL];

    [self.messages removeObjectAtIndex:indexPath.row];

    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showMessage"
                                  sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

- (NSString *)                                        tableView:(UITableView *)tableView
              titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Hide";
}


#pragma mark - Notifications
- (void)allConversationsDidChange:(NSNotification *)notification
{
    __block Conversation *newConversation;

    [self.conversationManager.allConversations enumerateObjectsUsingBlock:^(Conversation *updatedConversation, NSUInteger idx, BOOL *stop) {
        if ([self.conversation.conversationGUID isEqualToString:updatedConversation.conversationGUID]) {
            newConversation = updatedConversation;
            *stop = YES;
        }
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        // Keep track of the selected message so we can keep it highlighted
        Message *activeMessage;

        if (self.tableView.indexPathForSelectedRow) {
            activeMessage = self.messages[self.tableView.indexPathForSelectedRow.row];
        }

        self.conversation = newConversation;

        // Reset the selection on the active message
        if (activeMessage) {
            NSUInteger activeIndex = [self.messages indexOfObject:activeMessage];

            if (activeIndex != NSNotFound) {
                NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:activeIndex inSection:0];

                [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath]
                                      withRowAnimation:NO];

                // This is required to restore the highlight
                [self.tableView selectRowAtIndexPath:selectedIndexPath
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionNone];
            }
        }
    });
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
