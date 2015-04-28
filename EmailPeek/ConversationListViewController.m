/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "ConversationListViewController.h"
#import "SettingsViewController.h"
#import "MessageViewController.h"
#import "ConversationViewController.h"
#import "Conversation.h"
#import "MessagePreview.h"
#import "Message.h"
#import "EmailAddress.h"
#import "MessagePreviewCell.h"
#import "ConversationManager.h"
#import "SettingsManager.h"
#import "UIColor+Office365.h"
#import "NSDate+Office365.h"

static NSString * const CellIdentifier = @"MessagePreviewCell";

@interface ConversationListViewController () <SettingsViewControllerDelegate, MessageViewControllerDelegate>

@property (copy,   nonatomic) NSMutableArray *conversationList;
@property (assign, nonatomic) BOOL            conversationListNeedsRefresh;

@property (weak,   nonatomic) IBOutlet UIBarButtonItem         *statusBarButtonItem;
@property (weak,   nonatomic) IBOutlet UIBarButtonItem         *activityBarButtonItem;
@property (weak,   nonatomic)          UIActivityIndicatorView *activityIndicator;
@property (weak,   nonatomic)          UILabel                 *primaryStatusLabel;
@property (weak,   nonatomic)          UILabel                 *secondaryStatusLabel;

@end

@implementation ConversationListViewController

#pragma mark - Properties
- (void)setConversationManager:(ConversationManager *)conversationManager
{
    // Remove the existing notification registrations
    NSNotificationCenter *notificationCenter = _conversationManager.notificationCenter;

    [notificationCenter removeObserver:self
                                  name:nil
                                object:_conversationManager];

    // Set the instance variable to the new value
    _conversationManager = conversationManager;

    // Register for notifications on the new object
    notificationCenter = _conversationManager.notificationCenter;

    [notificationCenter addObserver:self
                           selector:@selector(allConversationsRefreshDidBegin:)
                               name:ConversationManagerAllConversationsRefreshDidBeginNotification
                             object:_conversationManager];

    [notificationCenter addObserver:self
                           selector:@selector(allConversationsRefreshDidEnd:)
                               name:ConversationManagerAllConversationsRefreshDidEndNotification
                             object:_conversationManager];

    [notificationCenter addObserver:self
                           selector:@selector(allConversationsRefreshDidFail:)
                               name:ConversationManagerAllConversationsRefreshDidFailNotification
                             object:_conversationManager];

    [notificationCenter addObserver:self
                           selector:@selector(allConversationsDidChange:)
                               name:ConversationManagerAllConversationsDidChangeNotification
                             object:_conversationManager];

    [self updateRefreshControl];
}

- (void)setConversationList:(NSMutableArray *)conversationList
{
    NSArray *ascendingList  = [conversationList sortedArrayUsingSelector:@selector(compare:)];
    NSArray *descendingList = [[ascendingList reverseObjectEnumerator] allObjects];

    _conversationList = [descendingList mutableCopy];

    if (self.conversationManager.isConnected) {
        [self updateUnreadCount];
    }

    [self.tableView reloadData];
}


#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.conversationListNeedsRefresh = YES;

    [self setupUI];
    [self updateRefreshControl];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self refreshConversationList];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"presentSettings"]) {
        UINavigationController *navigationVC = segue.destinationViewController;
        SettingsViewController *settingsVC   = navigationVC.viewControllers[0];

        settingsVC.settingsManager = self.conversationManager.settingsManager;
        settingsVC.delegate        = self;
    }
    else if ([segue.identifier isEqualToString:@"showMessage"]) {
        NSIndexPath  *selectedIndexPath    = [self.tableView indexPathForCell:sender];
        Conversation *selectedConversation = self.conversationList[selectedIndexPath.row];
        Message      *selectedMessage      = selectedConversation.newestMessage;

        UINavigationController *navigationVC = segue.destinationViewController;
        MessageViewController  *messageVC    = navigationVC.viewControllers[0];

        messageVC.conversationManager = self.conversationManager;
        messageVC.message             = selectedMessage;
        messageVC.delegate            = self;
    }
    else if ([segue.identifier isEqualToString:@"showConversation"]) {
        NSIndexPath                *selectedIndexPath = [self.tableView indexPathForCell:sender];
        ConversationViewController *conversationVC    = segue.destinationViewController;

        conversationVC.conversation        = self.conversationList[selectedIndexPath.row];
        conversationVC.conversationManager = self.conversationManager;
        conversationVC.delegate            = self;
    }
}

- (void)dealloc
{
    NSNotificationCenter *notificationCenter = _conversationManager.notificationCenter;

    [notificationCenter removeObserver:self
                                  name:nil
                                object:_conversationManager];
}


#pragma mark - UI Setup/Update
- (void)setupUI
{
    UIView  *statusView           = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 225, 32)];
    UILabel *primaryStatusLabel   = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 225, 16)];
    UILabel *secondaryStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 225, 12)];

    primaryStatusLabel.font            = [UIFont systemFontOfSize:13.0];
    secondaryStatusLabel.font          = [UIFont systemFontOfSize:10.0];

    primaryStatusLabel.textAlignment   = NSTextAlignmentCenter;
    secondaryStatusLabel.textAlignment = NSTextAlignmentCenter;

    primaryStatusLabel.textColor       = [UIColor o365_primaryColor];
    secondaryStatusLabel.textColor     = [UIColor grayColor];

    [statusView addSubview:primaryStatusLabel];
    [statusView addSubview:secondaryStatusLabel];

    self.primaryStatusLabel             = primaryStatusLabel;
    self.secondaryStatusLabel           = secondaryStatusLabel;

    self.statusBarButtonItem.customView = statusView;

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

    activityIndicator.color              = [UIColor o365_primaryColor];

    self.activityBarButtonItem.customView = activityIndicator;
    self.activityIndicator                = activityIndicator;

    self.refreshControl.backgroundColor = [UIColor o365_primaryColor];
    self.refreshControl.tintColor       = [UIColor whiteColor];

    UINib *cellNib = [UINib nibWithNibName:CellIdentifier
                                    bundle:nil];

    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:CellIdentifier];
    self.tableView.layoutMargins = UIEdgeInsetsZero;
}

- (void)updateRefreshControl
{
    NSString *lastUpdatedTitle = @"";
    NSDate   *lastUpdatedDate  = self.conversationManager.allConversationsRefreshDate;

    if (lastUpdatedDate) {
        lastUpdatedTitle = [NSString stringWithFormat:@"Last update on %@", [lastUpdatedDate o365_mediumString]];
    }

    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdatedTitle
                                                                          attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

- (void)updateStatusWithPrimaryMessage:(NSString *)primaryMessage
                      secondaryMessage:(NSString *)secondaryMessage
                    activityInProgress:(BOOL)activityInProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (primaryMessage) {
            self.primaryStatusLabel.text   = primaryMessage;
        }

        if (secondaryMessage) {
            self.secondaryStatusLabel.text = secondaryMessage;
        }

        if (activityInProgress) {
            [self.activityIndicator startAnimating];
        }
        else {
            [self.activityIndicator stopAnimating];
        }
    });
}

- (void)updateUnreadCount
{
    if (!self.conversationManager.allConversationsRefreshInProgress) {
        [self updateStatusWithPrimaryMessage:@"Fetch Complete"
                            secondaryMessage:[NSString stringWithFormat:@"You have %lu unread messages", (unsigned long)self.conversationManager.unreadMessageCount]
                          activityInProgress:NO];
    }
}

- (void)refreshConversationList
{
    if (!self.conversationListNeedsRefresh) {
        return;
    }

    self.conversationListNeedsRefresh = NO;


    if (!self.conversationManager.isConnected) {
        [self.conversationManager connectWithCompletionHandler:^(BOOL success, NSError *error) {
            if (success) {
                [self updateStatusWithPrimaryMessage:@"Connected Successfully"
                                    secondaryMessage:@"User successfully authenticated with the server."
                                  activityInProgress:NO];

                [self.conversationManager refreshAllConversations];
            }
            else {
                [self updateStatusWithPrimaryMessage:@"Connection Error"
                                    secondaryMessage:@"Unable to authenticate the user with the server."
                                  activityInProgress:NO];

                if (self.refreshControl.isRefreshing) {
                    [self.refreshControl endRefreshing];
                }
            }
        }];
    }
    else {
        [self.conversationManager refreshAllConversations];
    }
}


#pragma mark - Notifications
- (void)allConversationsRefreshDidBegin:(NSNotification *)notification
{
    [self updateStatusWithPrimaryMessage:@"Fetching Messages"
                        secondaryMessage:@"Contacting the server for the latest messages"
                      activityInProgress:YES];
}

- (void)allConversationsRefreshDidEnd:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateRefreshControl];
        [self updateUnreadCount];
        [self.refreshControl endRefreshing];
    });
}

- (void)allConversationsRefreshDidFail:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateRefreshControl];

        [self updateStatusWithPrimaryMessage:@"Fetch Failed"
                            secondaryMessage:[notification.userInfo[ConversationManagerAllConversationsErrorKey] localizedDescription]
                          activityInProgress:NO];
        [self.refreshControl endRefreshing];
    });
}

- (void)allConversationsDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Keep track of the selected converation to keep it highlighted
        Conversation *activeConversation;

        if (self.tableView.indexPathForSelectedRow) {
            activeConversation = self.conversationList[self.tableView.indexPathForSelectedRow.row];
        }

        self.conversationList = [self.conversationManager.allConversations mutableCopy];

        // Reset the selection on the active conversation
        if (activeConversation) {
            NSUInteger activeIndex = [self.conversationList indexOfObjectPassingTest:^BOOL(Conversation *conversation, NSUInteger idx, BOOL *stop) {
                return [activeConversation.conversationGUID isEqualToString:conversation.conversationGUID];
            }];

            if (activeIndex != NSNotFound) {
                NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:activeIndex inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath]
                                      withRowAnimation:NO];
                // This is required to bring back the highlight
                [self.tableView selectRowAtIndexPath:selectedIndexPath
                                            animated:NO
                                      scrollPosition:UITableViewScrollPositionNone];
            }
        }
    });
}


#pragma mark - IBActions
- (IBAction)unwindToConversationList:(UIStoryboardSegue *)sender
{
    // Segue for iPad
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self refreshConversationList];
                             }];
}

- (IBAction)refreshControlActivated
{
    self.conversationListNeedsRefresh = YES;
    [self refreshConversationList];
}


#pragma mark - UITableViewDataSource
- (NSInteger)            tableView:(UITableView *)tableView
             numberOfRowsInSection:(NSInteger)section
{
    return self.conversationList.count;
}

- (UITableViewCell *)            tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Conversation       *conversation = self.conversationList[indexPath.row];
    MessagePreviewCell *cell         = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                       forIndexPath:indexPath];

    cell.messagePreview = conversation;

    return cell;
}

- (BOOL)            tableView:(UITableView *)tableView
        canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Conversation *conversation = self.conversationList[indexPath.row];
    return (conversation.messageCount == 1);
}

- (void)         tableView:(UITableView *)tableView
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
         forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    Conversation *conversation = self.conversationList[indexPath.row];

    [self.conversationManager markMessage:conversation.messages.firstObject
                                 isHidden:YES
                        completionHandler:NULL];
    [self.conversationList removeObjectAtIndex:indexPath.row];

    [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Conversation *selectedConversation = self.conversationList[indexPath.row];

    if (selectedConversation.messageCount > 1) {
        [self performSegueWithIdentifier:@"showConversation"
                                  sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
    else {
        [self performSegueWithIdentifier:@"showMessage"
                                  sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (NSString *)                                        tableView:(UITableView *)tableView
              titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Hide";
}


#pragma mark - SettingsViewControllerDelegate
- (void)settingsViewControllerShouldDisconnect:(SettingsViewController *)settingsVC
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 [self.conversationManager disconnectWithCompletionHandler:^(BOOL success, NSError *error) {
                                     [self updateStatusWithPrimaryMessage:@"Successfully Disconnected"
                                                         secondaryMessage:@"Pull to reconnect."
                                                       activityInProgress:NO];

                                     self.conversationListNeedsRefresh = YES;
                                     [self refreshConversationList];
                                 }];
                             }];
}

- (void)settingsViewControllerDidChangeSettings:(SettingsViewController *)settingsVC
{
    self.conversationListNeedsRefresh = YES;
}


#pragma mark - MessageViewControllerDelegate
- (void)messageViewController:(MessageViewController *)messageViewController
               shouldReplyAll:(BOOL)replyAll
                    toMessage:(Message *)message
                 withResponse:(NSString *)response
{
    [self.navigationController popToViewController:self
                                          animated:YES];

    [self updateStatusWithPrimaryMessage:@"Sending Reply"
                        secondaryMessage:nil
                      activityInProgress:YES];

    [self.conversationManager replyToMessage:message
                                    replyAll:replyAll
                                responseBody:response
                           completionHandler:^(BOOL success, NSError *error) {
                               NSString *primaryMessage;
                               NSString *secondaryMessage;

                               if (success) {
                                   primaryMessage = @"Reply Sent Successfully";
                               }
                               else {
                                   primaryMessage   = @"Unable To Send Reply";
                                   secondaryMessage = @"Please try again.";
                               }

                               [self updateStatusWithPrimaryMessage:primaryMessage
                                                   secondaryMessage:secondaryMessage
                                                 activityInProgress:NO];
                           }];
}

- (BOOL)      messageViewController:(MessageViewController *)messageViewController
        isFollowingSenderForMessage:(Message *)message
{
    return [self.conversationManager.settingsManager isFollowingSenderEmailAddress:message.sender];
}

- (BOOL)            messageViewController:(MessageViewController *)messageViewController
        isFollowingConversationForMessage:(Message *)message
{
    return [self.conversationManager.settingsManager isFollowingConversation:message];
}

- (void)messageViewController:(MessageViewController *)messageViewController
           shouldFollowSender:(BOOL)shouldFollow
                   forMessage:(Message *)message
{
    if (shouldFollow) {
        [self.conversationManager.settingsManager followSenderEmailAddress:message.sender];
    }
    else {
        [self.conversationManager.settingsManager unfollowSenderEmailAddress:message.sender];
    }

    // Refresh here is needed for iPad where the conversation list is already on the
    // screen and there won't be an event to start refreshing otherwise
    self.conversationListNeedsRefresh = YES;
    [self refreshConversationList];
}

- (void)   messageViewController:(MessageViewController *)messageViewController
        shouldFollowConversation:(BOOL)shouldFollow
                      forMessage:(Message *)message
{
    if (shouldFollow) {
        [self.conversationManager.settingsManager followConversation:message];
    }
    else {
        [self.conversationManager.settingsManager unfollowConversation:message];
    }

    // Refresh here is needed for iPad where the conversation list is already on the
    // screen and there won't be an event to start refreshing otherwise
    self.conversationListNeedsRefresh = YES;
    [self refreshConversationList];
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
