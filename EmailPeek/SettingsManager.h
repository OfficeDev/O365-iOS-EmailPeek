/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import <Foundation/Foundation.h>

#import "MessagePreview.h"

@class SenderFilter;
@class ConversationFilter;

@interface SettingsManager : NSObject

// General settings
@property (assign,   nonatomic) BOOL        updateServerSideReadStatus;

// Message consideration criteria
@property (assign,   nonatomic) NSUInteger  daysBackToConsider;
@property (readonly, nonatomic) NSDate     *startingDate;

@property (assign,   nonatomic) BOOL        includeUrgentMessages;
@property (assign,   nonatomic) BOOL        includeUnreadMessages;

@property (readonly, nonatomic) NSArray    *senderFilterList;
@property (readonly, nonatomic) NSArray    *conversationFilterList;

// Dependencies
@property (strong,   nonatomic) NSNotificationCenter *notificationCenter;


- (void)restoreDefaultSettings;

// When working with the original objects
- (void)followSenderEmailAddress:(EmailAddress *)emailAddress;
- (void)followConversation:(id<MessagePreview>)messagePreview;

- (void)unfollowSenderEmailAddress:(EmailAddress *)emailAddress;
- (void)unfollowConversation:(id<MessagePreview>)messagePreview;

- (BOOL)isFollowingSenderEmailAddress:(EmailAddress *)emailAddress;
- (BOOL)isFollowingConversation:(id<MessagePreview>)messagePreview;

// When working with the MessageFilter objects
- (void)addSenderFilter:(SenderFilter *)senderFilter;
- (void)addConversationFilter:(ConversationFilter *)conversationFilter;

- (void)removeSenderFilter:(SenderFilter *)senderFilter;
- (void)removeConversationFilter:(ConversationFilter *)conversationFilter;

- (BOOL)save;
- (BOOL)reload;

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

