/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "Message.h"

@implementation Message

@synthesize guid             = _guid;
@synthesize conversationGUID = _conversationGUID;
@synthesize subject          = _subject;
@synthesize sender           = _sender;
@synthesize toRecipients     = _toRecipients;
@synthesize ccRecipients     = _ccRecipients;
@synthesize bodyPreview      = _bodyPreview;
@synthesize dateReceived     = _dateReceived;
@synthesize isReadOnServer   = _isReadOnServer;
@synthesize isReadOnClient   = _isReadOnClient;
@synthesize isRead           = _isRead;
@synthesize isHidden         = _isHidden;
@synthesize hasAttachments   = _hasAttachments;
@synthesize importance       = _importance;
@synthesize categories       = _categories;


#pragma mark - Initialization
- (instancetype)init
{
    return [self initWithGUID:nil
             conversationGUID:nil
                      subject:nil
                       sender:nil
                 toRecipients:nil
                 ccRecipients:nil
                  bodyPreview:nil
                 dateReceived:nil
               isReadOnServer:NO
               isReadOnClient:NO
                     isHidden:NO
               hasAttachments:NO
                   importance:MessageImportanceNormal
                   categories:nil];
}

- (instancetype)initWithGUID:(NSString *)guid
            conversationGUID:(NSString *)conversationGUID
                     subject:(NSString *)subject
                      sender:(EmailAddress *)sender
                toRecipients:(NSArray *)toRecipients
                ccRecipients:(NSArray *)ccRecipients
                 bodyPreview:(NSString *)bodyPreview
                dateReceived:(NSDate *)dateReceived
              isReadOnServer:(BOOL)isReadOnServer
              isReadOnClient:(BOOL)isReadOnClient
                    isHidden:(BOOL)isHidden
              hasAttachments:(BOOL)hasAttachments
                  importance:(MessageImportance)importance
                  categories:(NSArray *)categories
{
    self = [super init];

    if (self) {
        _guid             = [guid copy];
        _conversationGUID = [conversationGUID copy];
        _subject          = [subject copy];
        _sender           = sender;
        _toRecipients     = toRecipients ? [toRecipients copy] : @[];
        _ccRecipients     = ccRecipients ? [ccRecipients copy] : @[];
        _bodyPreview      = [bodyPreview copy];
        _dateReceived     = dateReceived;
        _isReadOnServer   = isReadOnServer;
        _isReadOnClient   = isReadOnClient;
        _isRead           = isReadOnServer || isReadOnClient;
        _isHidden         = isHidden;
        _hasAttachments   = hasAttachments;
        _importance       = importance;
        _categories       = [categories copy];
    }

    return self;
}


#pragma mark - Properties
- (NSUInteger)messageCount
{
    return 1;
}


#pragma mark - Convenience Methods
- (NSComparisonResult)compare:(id<MessagePreview>)object
{
    return [self.dateReceived compare:object.dateReceived];
}


#pragma mark - NSObject
- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[Message class]]) {
        return NO;
    }

    return [self.guid isEqualToString:[object guid]];
}

- (NSUInteger)hash
{
    return [self.guid hash];
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

