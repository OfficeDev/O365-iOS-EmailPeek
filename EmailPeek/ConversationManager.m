/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "ConversationManager.h"

#import "Office365Client.h"
#import "SettingsManager.h"
#import "Message.h"
#import "Conversation.h"

#import "MessageFilter.h"
#import "NothingFilter.h"
#import "UnreadFilter.h"
#import "ImportanceFilter.h"
#import "ConversationFilter.h"

NSString * const ConversationManagerAllConversationsDidChangeNotification       = @"ConversationManagerAllConversationsDidChangeNotification";

NSString * const ConversationManagerAllConversationsRefreshDidBeginNotification = @"ConversationManagerAllConversationsRefreshDidBeginNotification";
NSString * const ConversationManagerAllConversationsRefreshDidEndNotification   = @"ConversationManagerAllConversationsRefreshDidEndNotification";
NSString * const ConversationManagerAllConversationsRefreshDidFailNotification  = @"ConversationManagerAllConversationsRefreshDidFailNotification";

NSString * const ConversationManagerAllConversationsMessageCountKey             = @"ConversationManagerAllConversationsMessageCountKey";
NSString * const ConversationManagerAllConversationsUnreadMessageCountKey       = @"ConversationManagerAllConversationsUnreadMessageCountKey";
NSString * const ConversationManagerAllConversationsErrorKey                    = @"ConversationManagerAllConversationsErrorKey";

static NSString * const kResponseSignature = @"Sent from EmailPeek on iOS";

@interface ConversationManager ()

@property (readwrite, copy,   nonatomic) NSArray *allConversations;
@property (readwrite, strong, nonatomic) NSDate  *allConversationsRefreshDate;
@property (readwrite, assign, nonatomic) BOOL     allConversationsRefreshInProgress;

@property (strong,   nonatomic) NSMutableSet *allMessages;
@property (readonly, nonatomic) NSString     *combinedServerSideFilter;

@end

@implementation ConversationManager

#pragma mark - Properties
- (NSMutableSet *)allMessages
{
    if (!_allMessages) {
        _allMessages = [[NSMutableSet alloc] init];
    }

    return _allMessages;
}

- (NSNotificationCenter *)notificationCenter
{
    if (!_notificationCenter) {
        _notificationCenter = [NSNotificationCenter defaultCenter];
    }

    return _notificationCenter;
}

- (void)setAllConversations:(NSArray *)allConversations
{
    _allConversations = [allConversations copy];

    NSDictionary *userInfo = @{ConversationManagerAllConversationsMessageCountKey       : @(self.messageCount),
                               ConversationManagerAllConversationsUnreadMessageCountKey : @(self.unreadMessageCount)};

    [self.notificationCenter postNotificationName:ConversationManagerAllConversationsDidChangeNotification
                                           object:self
                                         userInfo:userInfo];
}

// This method builds the string for the REST API for the filtering
// of the messages.
- (NSString *)combinedServerSideFilter
{
    NSMutableArray *allFilters = [[NSMutableArray alloc] init];

    [allFilters addObjectsFromArray:self.settingsManager.conversationFilterList];
    [allFilters addObjectsFromArray:self.settingsManager.senderFilterList];

    if (self.settingsManager.includeUnreadMessages) {
        [allFilters addObject:[[UnreadFilter alloc] init]];
    }

    if (self.settingsManager.includeUrgentMessages) {
        [allFilters addObject:[[ImportanceFilter alloc] init]];
    }

    if (allFilters.count == 0) {
        [allFilters addObject:[[NothingFilter alloc] init]];
    }

    NSArray *serverSideFilters = [allFilters valueForKeyPath:@"@unionOfObjects.serverSideFilter"];

    return [serverSideFilters componentsJoinedByString:@" or "];
}

- (NSArray *)quickResponseBodies
{
    return @[@"I'll get back to you shortly.", @"Thank you!", @"Sounds great."];
}

- (NSUInteger)messageCount
{
    return self.allMessages.count;
}

- (NSUInteger)unreadMessageCount
{
    NSUInteger unreadMessageCount = 0;

    for (Message *message in self.allMessages) {
        if (!message.isHidden && !message.isRead) {
            unreadMessageCount++;
        }
    }

    return unreadMessageCount;
}


#pragma mark - Public Methods
- (void)refreshAllConversations
{
    // Move to a concurrent queue to ensure there are no race conditions
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.allConversationsRefreshInProgress) { return; }

        self.allConversationsRefreshInProgress = YES;

        [self.notificationCenter postNotificationName:ConversationManagerAllConversationsRefreshDidBeginNotification
                                               object:self];

        [self.office365Client fetchMessagesFromDate:self.settingsManager.startingDate
                                         withFilter:self.combinedServerSideFilter
                                  completionHandler:^(NSSet *messages, NSError *error) {
                                      NSString            *notificationToPost;
                                      NSMutableDictionary *notificationUserInfo = [[NSMutableDictionary alloc] init];

                                      if (messages) {
                                          self.allMessages                 = [messages mutableCopy];
                                          self.allConversations            = [self conversationsFromMessages:[self.allMessages allObjects]];
                                          self.allConversationsRefreshDate = [NSDate date];

                                          notificationToPost = ConversationManagerAllConversationsRefreshDidEndNotification;
                                      }
                                      else {
                                          NSLog(@"ERROR: Trouble fetching messages {%@}", [error localizedDescription]);

                                          notificationToPost = ConversationManagerAllConversationsRefreshDidFailNotification;
                                          notificationUserInfo[ConversationManagerAllConversationsErrorKey] = error;
                                      }

                                      // Unset the flag on the same concurrent queue
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.allConversationsRefreshInProgress = NO;
                                      });

                                      notificationUserInfo[ConversationManagerAllConversationsMessageCountKey]       = @(self.messageCount);
                                      notificationUserInfo[ConversationManagerAllConversationsUnreadMessageCountKey] = @(self.unreadMessageCount);
                                      
                                      [self.notificationCenter postNotificationName:notificationToPost
                                                                             object:self
                                                                           userInfo:notificationUserInfo];
                                  }];
    });
}

- (void)messageDetailForMessage:(Message *)message
              completionHandler:(void (^)(MessageDetail *, NSError *))completionHandler
{
    [self.office365Client fetchMessageDetailForMessage:message
                                     completionHandler:^(MessageDetail *messageDetail, NSError *error) {
                                         completionHandler(messageDetail, error);
                                     }];
}

- (void)markMessage:(Message *)message
             isRead:(BOOL)isRead
{
    [self.office365Client markMessage:message
                               isRead:isRead
                    updateOutlookFlag:self.settingsManager.updateServerSideReadStatus
                    completionHandler:^(Message *updatedMessage, NSError *error) {
                        if (!updatedMessage) {
                            NSLog(@"ERROR: Could not mark message as read {%@}", error);
                            return;
                        }

                        [self.allMessages removeObject:message];
                        [self.allMessages addObject:updatedMessage];

                        self.allConversations = [self conversationsFromMessages:[self.allMessages allObjects]];
                    }];
}

- (void)      markMessage:(Message *)message
                 isHidden:(BOOL)isHidden
        completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler
{
    [self.office365Client markMessage:message
                             isHidden:isHidden
                    completionHandler:^(Message *updatedMessage, NSError *error) {
                        if (!updatedMessage) {
                            NSLog(@"ERROR: Could not mark message as hidden {%@}", error);
                            completionHandler(nil, error);
                            return;
                        }

                        [self.allMessages removeObject:message];
                        [self.allMessages addObject:updatedMessage];
                        
                        self.allConversations = [self conversationsFromMessages:[self.allMessages allObjects]];

                        if(completionHandler)
                            completionHandler(updatedMessage, nil);
                    }];
}

- (void)replyToMessage:(Message *)message
              replyAll:(BOOL)replyAll
          responseBody:(NSString *)responseBody
     completionHandler:(void (^)(BOOL, NSError *))completionHandler
{
    NSString *responseWithSignature = [NSString stringWithFormat:@"%@<br/><br/>%@", responseBody, kResponseSignature];

    [self.office365Client replyToMessage:message
                                replyAll:replyAll
                            responseBody:responseWithSignature
                       completionHandler:completionHandler];
}


#pragma mark - Connection Methods
- (BOOL)isConnected
{
    return self.office365Client.isConnected;
}

- (void)connectWithCompletionHandler:(void (^)(BOOL, NSError *))completionHandler
{
    [self.office365Client connectWithCompletionHandler:completionHandler];
}

- (void)disconnectWithCompletionHandler:(void (^)(BOOL, NSError *))completionHandler
{
    [self.office365Client disconnectWithCompletionHandler:^(BOOL success, NSError *error) {
        [self.settingsManager restoreDefaultSettings];
        [self.settingsManager save];

        self.allMessages      = nil;
        self.allConversations = nil;

        completionHandler(success, error);
    }];
}

#pragma mark - Helper Methods
- (NSArray *)conversationsFromMessages:(NSArray *)messages
{
    NSMutableDictionary *messagesByConversationGUID = [[NSMutableDictionary alloc] init];

    NSArray *filteredMessages = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isHidden == NO"]];

    for (Message *message in filteredMessages) {
        NSMutableArray *messages = messagesByConversationGUID[message.conversationGUID];

        if (!messages) {
            messages = [[NSMutableArray alloc] init];

            messagesByConversationGUID[message.conversationGUID] = messages;
        }

        [messages addObject:message];
    }

    NSMutableArray *conversations = [[NSMutableArray alloc] init];

    for (NSString *conversationGUID in messagesByConversationGUID) {
        NSMutableArray *messages = messagesByConversationGUID[conversationGUID];

        Conversation *conversation = [[Conversation alloc] initWithGUID:conversationGUID
                                                               messages:messages];

        [conversations addObject:conversation];
    }

    return [conversations sortedArrayUsingSelector:@selector(compare:)];
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
