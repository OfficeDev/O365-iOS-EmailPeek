/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "SenderFilter.h"

#import "EmailAddress.h"

@implementation SenderFilter

#pragma mark - Initialization
- (instancetype)init
{
    return [self initWithEmailAddress:nil];
}

- (instancetype)initWithEmailAddress:(EmailAddress *)emailAddress
{
    self = [super init];

    if (self) {
        _emailAddress = emailAddress;
    }

    return self;
}


#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        _emailAddress = [aDecoder decodeObjectForKey:@"emailAddress"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.emailAddress forKey:@"emailAddress"];
}


#pragma mark - NSObject
- (NSString *)description
{
    return [self.emailAddress description];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[SenderFilter class]]) {
        return NO;
    }

    return [self.emailAddress isEqual:[object emailAddress]];
}

- (NSUInteger)hash
{
    return [self.emailAddress hash];
}


#pragma mark - MessageFilter
- (NSString *)serverSideFilter
{
    return [NSString stringWithFormat:@"Sender/EmailAddress/Address eq '%@'", self.emailAddress.address];
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

