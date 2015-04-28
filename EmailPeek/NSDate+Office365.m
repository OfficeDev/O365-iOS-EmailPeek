/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "NSDate+Office365.h"

//Helpers for formatting dates
@implementation NSDate (Office365)

- (NSString *)o365_relativeString
{
    NSString       *relativeDate;
    NSCalendar     *currentCalendar       = [NSCalendar currentCalendar];
    NSTimeInterval  secondsBackForDayOnly = 6 * 60 * 60 * 24;
    NSDate         *dayOnlyCutoffDate     = [NSDate dateWithTimeIntervalSinceNow:-secondsBackForDayOnly];

    if ([currentCalendar isDateInToday:self]) {
        relativeDate = [NSDateFormatter localizedStringFromDate:self
                                                      dateStyle:NSDateFormatterNoStyle
                                                      timeStyle:NSDateFormatterShortStyle];
    }
    else if ([currentCalendar isDateInYesterday:self]) {
        relativeDate = @"Yesterday";
    }
    else if ([self compare:dayOnlyCutoffDate] == NSOrderedDescending) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

        dateFormatter.dateFormat = @"EEEE";

        relativeDate = [dateFormatter stringFromDate:self];
    }
    else {
        relativeDate = [NSDateFormatter localizedStringFromDate:self
                                                      dateStyle:NSDateFormatterShortStyle
                                                      timeStyle:NSDateFormatterNoStyle];
    }

    return relativeDate;
}

- (NSString *)o365_mediumString
{
    static NSDateFormatter *dateFormatter;

    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];

        dateFormatter.dateFormat = @"MMMM d, YYYY 'at' h:mm a";
    }

    return [dateFormatter stringFromDate:self];
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

