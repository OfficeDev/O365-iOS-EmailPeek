/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "Conversation.h"

#import "Message.h"

@implementation Conversation

@synthesize guid           = _guid;
@synthesize unreadMessages = _unreadMessages;

#pragma mark - Initialization
- (instancetype)init
{
    return [self initWithMessages:nil];
}

- (instancetype)initWithMessages:(NSArray *)messages
{
    return [self initWithGUID:[[messages firstObject] conversationGUID]
                     messages:messages];
}

- (instancetype)initWithGUID:(NSString *)guid
                    messages:(NSArray *)messages
{
    self = [super init];

    if (self) {
        _guid     = [guid copy];
        _messages = [messages sortedArrayUsingSelector:@selector(compare:)];
    }

    return self;
}

#pragma mark - Properties
- (NSArray *)unreadMessages
{
    if (!_unreadMessages) {
        NSMutableArray *unreadMessages = [[NSMutableArray alloc] init];

        for (Message *message in self.messages) {
            if (!message.isRead) {
                [unreadMessages addObject:message];
            }
        }

        _unreadMessages = [unreadMessages copy];
    }

    return _unreadMessages;
}

- (Message *)oldestMessage
{
    return [self.messages firstObject];
}

- (Message *)newestMessage
{
    return [self.messages lastObject];
}

- (Message *)oldestUnreadMessage
{
    return [self.unreadMessages firstObject];
}

- (Message *)previewMessage
{
    return self.oldestUnreadMessage ? self.oldestUnreadMessage : self.newestMessage;
}

- (NSUInteger)messageCount
{
    return self.messages.count;
}

- (NSUInteger)unreadMessageCount
{
    return self.unreadMessages.count;
}

#pragma mark - MessagePreview
- (NSString *)conversationGUID
{
    return self.guid;
}

- (NSString *)subject
{
    return self.oldestMessage.subject;
}

- (EmailAddress *)sender
{
    return self.previewMessage.sender;
}

- (NSArray *)toRecipients
{
    return self.previewMessage.toRecipients;
}

- (NSArray *)ccRecipients
{
    return self.previewMessage.ccRecipients;
}

- (NSString *)bodyPreview
{
    return self.previewMessage.bodyPreview;
}

- (NSDate *)dateReceived
{
    return self.newestMessage.dateReceived;
}

- (BOOL)isReadOnServer
{
    return self.previewMessage.isReadOnServer;
}

- (BOOL)isReadOnClient
{
    return self.previewMessage.isReadOnClient;
}

- (BOOL)isRead
{
    return self.previewMessage.isRead;
}

- (BOOL)isHidden
{
    for (Message *message in self.messages) {
        if (!message.isHidden) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)hasAttachments
{
    return self.previewMessage.hasAttachments;
}

- (MessageImportance)importance
{
    return self.previewMessage.importance;
}

- (NSArray *)categories
{
    return self.previewMessage.categories;
}

- (NSComparisonResult)compare:(id<MessagePreview>)object
{
    return [self.dateReceived compare:object.dateReceived];
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

