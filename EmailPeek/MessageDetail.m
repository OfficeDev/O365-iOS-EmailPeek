/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "MessageDetail.h"

@implementation MessageDetail

#pragma mark - Initialization
- (instancetype)init
{
    return [self initWithGUID:nil
                         body:nil
                   isBodyHTML:NO
                   uniqueBody:nil
             isUniqueBodyHTML:NO
                  attachments:nil];
}

- (instancetype)initWithGUID:(NSString *)guid
                        body:(NSString *)body
                  isBodyHTML:(BOOL)isBodyHTML
                  uniqueBody:(NSString *)uniqueBody
            isUniqueBodyHTML:(BOOL)isUniqueBodyHTML
                 attachments:(NSArray *)attachments
{
    self = [super init];

    if (self) {
        _guid             = [guid copy];
        _body             = [body copy];
        _isBodyHTML       = isBodyHTML;
        _uniqueBody       = [uniqueBody copy];
        _isUniqueBodyHTML = isUniqueBodyHTML;
        _attachments      = [attachments copy];
    }

    return self;
}

#pragma mark - NSObject
- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[MessageDetail class]]) {
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

