/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import <Foundation/Foundation.h>

#import "EmailAddress.h"

typedef NS_ENUM(NSUInteger, MessageImportance) {
    MessageImportanceLow,
    MessageImportanceNormal,
    MessageImportanceHigh,
};

@protocol MessagePreview <NSObject>

@property (readonly, nonatomic) NSString          *guid;
@property (readonly, nonatomic) NSString          *conversationGUID;
@property (readonly, nonatomic) NSString          *subject;
@property (readonly, nonatomic) EmailAddress      *sender;
@property (readonly, nonatomic) NSArray           *toRecipients;
@property (readonly, nonatomic) NSArray           *ccRecipients;
@property (readonly, nonatomic) NSString          *bodyPreview;
@property (readonly, nonatomic) NSDate            *dateReceived;
@property (readonly, nonatomic) BOOL               isReadOnServer;
@property (readonly, nonatomic) BOOL               isReadOnClient;
@property (readonly, nonatomic) BOOL               isRead;
@property (readonly, nonatomic) BOOL               isHidden;
@property (readonly, nonatomic) BOOL               hasAttachments;
@property (readonly, nonatomic) MessageImportance  importance;
@property (readonly, nonatomic) NSArray           *categories;
@property (readonly, nonatomic) NSUInteger         messageCount;

- (NSComparisonResult)compare:(id<MessagePreview>)object;

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
