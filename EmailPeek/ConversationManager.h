/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Office365Client;
@class SettingsManager;
@class Message;
@class MessageDetail;

extern NSString * const ConversationManagerAllConversationsDidChangeNotification;

extern NSString * const ConversationManagerAllConversationsRefreshDidBeginNotification;
extern NSString * const ConversationManagerAllConversationsRefreshDidEndNotification;
extern NSString * const ConversationManagerAllConversationsRefreshDidFailNotification;

extern NSString * const ConversationManagerAllConversationsMessageCountKey;
extern NSString * const ConversationManagerAllConversationsUnreadMessageCountKey;

extern NSString * const ConversationManagerAllConversationsErrorKey;

@interface ConversationManager : NSObject

// Dependencies of this class
@property (strong, nonatomic) UIApplication        *application;
@property (strong, nonatomic) Office365Client      *office365Client;
@property (strong, nonatomic) SettingsManager      *settingsManager;
@property (strong, nonatomic) NSNotificationCenter *notificationCenter;


@property (readonly, copy,   nonatomic) NSArray *allConversations;
@property (readonly, strong, nonatomic) NSDate  *allConversationsRefreshDate;
@property (readonly, assign, nonatomic) BOOL     allConversationsRefreshInProgress;

@property (readonly, strong, nonatomic) NSArray *quickResponseBodies;

@property (readonly, nonatomic) NSUInteger messageCount;
@property (readonly, nonatomic) NSUInteger unreadMessageCount;

@property (readonly, nonatomic) BOOL       isConnected;

- (void)refreshAllConversations;

- (void)messageDetailForMessage:(Message *)message
              completionHandler:(void (^)(MessageDetail *messageDetail, NSError *error))completionHandler;

/**
 If the user has indicated that they want to mark the read status on the server,
 then this method will update the read status in Outlook.  If the user has not
 set that flag, then the message will be updated on the server with a new
 category called 'EmailPeek - Read'.
 */
- (void)markMessage:(Message *)message
             isRead:(BOOL)isRead;
- (void)      markMessage:(Message *)message
                 isHidden:(BOOL)isHidden
        completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler;

- (void)replyToMessage:(Message *)message
              replyAll:(BOOL)replyAll
          responseBody:(NSString *)responseBody
     completionHandler:(void (^)(BOOL success, NSError *))completionHandler;


// Connection Related Methods
- (void)connectWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
- (void)disconnectWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

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

