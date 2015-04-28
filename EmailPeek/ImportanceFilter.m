/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "ImportanceFilter.h"

@implementation ImportanceFilter

#pragma mark - Initialization
- (instancetype)init
{
    return [self initWithMessageImportance:MessageImportanceHigh];
}

- (instancetype)initWithMessageImportance:(MessageImportance)messageImportance
{
    self = [super init];

    if (self) {
        _messageImportance = messageImportance;
    }

    return self;
}


#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        _messageImportance = [aDecoder decodeIntegerForKey:@"messageImportance"];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.messageImportance forKey:@"messageImportance"];
}


#pragma mark - MessageFilter
- (NSString *)serverSideFilter
{
    // NOTE: The example provided at https://msdn.microsoft.com/office/office365/APi/complex-types-for-mail-contacts-calendar#UseODataqueryparametersFilterrequests
    //       suggests that the following should work, but I didn't have success:
    //
    //       Importance eq Microsoft.Exchange.Services.OData.Model.Importance'High'

    // This might seem like overkill, but I didn't want to rely on the order
    // that the enumeration was declared; we could optimize this with a static
    // but it isn't going to be a significant savings
    NSArray    *importanceLookup = @[@(MessageImportanceLow),
                                     @(MessageImportanceNormal),
                                     @(MessageImportanceHigh)];

    NSUInteger  importanceValue  = [importanceLookup indexOfObject:@(self.messageImportance)];

    return [NSString stringWithFormat:@"Importance eq '%lu'", (unsigned long)importanceValue];
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

