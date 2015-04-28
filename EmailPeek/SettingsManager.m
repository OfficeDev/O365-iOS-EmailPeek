/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "SettingsManager.h"

#import "SenderFilter.h"
#import "ConversationFilter.h"
#import "EmailAddress.h"

static NSString * const kArchiveFileName = @"settings.archive";

@interface SettingsManager ()

@property (readonly, nonatomic) NSURL          *saveURL;

@property (strong,   nonatomic) NSMutableArray *mutableSenderFilterList;
@property (strong,   nonatomic) NSMutableArray *mutableConversationFilterList;

@end

@implementation SettingsManager

#pragma mark - Initialization
- (instancetype)init
{
    self = [super init];

    if (self) {
        [self restoreDefaultSettings];
    }

    return self;
}


#pragma mark - Properties
- (NSURL *)saveURL
{
    NSArray *documentURLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                   inDomains:NSUserDomainMask];

    return [documentURLs[0] URLByAppendingPathComponent:@"settings.archive"];
}

- (NSMutableArray *)mutableSenderFilterList
{
    if (!_mutableSenderFilterList) {
        _mutableSenderFilterList = [[NSMutableArray alloc] init];
    }

    return _mutableSenderFilterList;
}

- (NSMutableArray *)mutableConversationFilterList
{
    if (!_mutableConversationFilterList) {
        _mutableConversationFilterList = [[NSMutableArray alloc] init];
    }

    return _mutableConversationFilterList;
}

- (NSArray *)senderFilterList
{
    return [self.mutableSenderFilterList copy];
}

- (NSArray *)conversationFilterList
{
    return [self.mutableConversationFilterList copy];
}

- (NSDate *)startingDate
{
    NSTimeInterval secondsBackToConsider = self.daysBackToConsider * 60 * 60 * 24;

    NSDate *daysAgoDate = [NSDate dateWithTimeIntervalSinceNow:-secondsBackToConsider];

    return [[NSCalendar currentCalendar] startOfDayForDate:daysAgoDate];
}

- (NSNotificationCenter *)notificationCenter
{
    if (!_notificationCenter) {
        _notificationCenter = [NSNotificationCenter defaultCenter];
    }

    return _notificationCenter;
}


#pragma mark - Follow Lists
- (void)followSenderEmailAddress:(EmailAddress *)emailAddress
{
    SenderFilter *senderFilter = [[SenderFilter alloc] initWithEmailAddress:emailAddress];

    [self addSenderFilter:senderFilter];
}

- (void)followConversation:(id<MessagePreview>)messagePreview
{
    ConversationFilter *conversationFilter = [[ConversationFilter alloc] initWithConversationGUID:messagePreview.conversationGUID
                                                                              conversationSubject:messagePreview.subject];

    [self addConversationFilter:conversationFilter];
}

- (void)unfollowSenderEmailAddress:(EmailAddress *)emailAddress
{
    SenderFilter *senderFilter = [[SenderFilter alloc] initWithEmailAddress:emailAddress];

    [self removeSenderFilter:senderFilter];
}

- (void)unfollowConversation:(id<MessagePreview>)messagePreview
{
    ConversationFilter *conversationFilter = [[ConversationFilter alloc] initWithConversationGUID:messagePreview.conversationGUID
                                                                              conversationSubject:messagePreview.subject];

    [self removeConversationFilter:conversationFilter];
}

- (BOOL)isFollowingSenderEmailAddress:(EmailAddress *)emailAddress
{
    SenderFilter *senderFilter = [[SenderFilter alloc] initWithEmailAddress:emailAddress];

    return [self.mutableSenderFilterList containsObject:senderFilter];
}

- (BOOL)isFollowingConversation:(id<MessagePreview>)messagePreview
{
    ConversationFilter *conversationFilter = [[ConversationFilter alloc] initWithConversationGUID:messagePreview.conversationGUID
                                                                              conversationSubject:messagePreview.subject];

    return [self.mutableConversationFilterList containsObject:conversationFilter];
}

- (void)addSenderFilter:(SenderFilter *)senderFilter
{
    if ([self.mutableSenderFilterList containsObject:senderFilter]) {
        return;
    }

    [self.mutableSenderFilterList addObject:senderFilter];
}

- (void)addConversationFilter:(ConversationFilter *)conversationFilter
{
    if ([self.mutableConversationFilterList containsObject:conversationFilter]) {
        return;
    }

    [self.mutableConversationFilterList addObject:conversationFilter];
}

- (void)removeSenderFilter:(SenderFilter *)senderFilter
{
    [self.mutableSenderFilterList removeObject:senderFilter];
}

- (void)removeConversationFilter:(ConversationFilter *)conversationFilter
{
    [self.mutableConversationFilterList removeObject:conversationFilter];
}


#pragma mark - Misc Public Methods
- (void)restoreDefaultSettings
{
    self.updateServerSideReadStatus    = NO;

    self.daysBackToConsider            = 7;
    self.includeUrgentMessages         = YES;
    self.includeUnreadMessages         = YES;

    self.mutableSenderFilterList       = nil;
    self.mutableConversationFilterList = nil;
}

- (BOOL)save
{
    // Wrap up all of the settings in a dictionary, and persist the dictionary
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];

    settings[@"updateServerSideReadStatus"]    = @(self.updateServerSideReadStatus);
    settings[@"daysBackToConsider"]            = @(self.daysBackToConsider);
    settings[@"includeUrgentMessages"]         = @(self.includeUrgentMessages);
    settings[@"includeUnreadMessages"]         = @(self.includeUnreadMessages);
    settings[@"mutableSenderFilterList"]       =   self.mutableSenderFilterList;
    settings[@"mutableConversationFilterList"] =   self.mutableConversationFilterList;

    return [NSKeyedArchiver archiveRootObject:settings
                                       toFile:[self.saveURL path]];
}

- (BOOL)reload
{
    NSDictionary *settings = [NSKeyedUnarchiver unarchiveObjectWithFile:[self.saveURL path]];

    if (!settings) {
        return NO;
    }

    self.updateServerSideReadStatus    = [settings[@"updateServerSideReadStatus"] boolValue];
    self.daysBackToConsider            = [settings[@"daysBackToConsider"]         unsignedIntegerValue];
    self.includeUrgentMessages         = [settings[@"includeUrgentMessages"]      boolValue];
    self.includeUnreadMessages         = [settings[@"includeUnreadMessages"]      boolValue];
    self.mutableSenderFilterList       =  settings[@"mutableSenderFilterList"];
    self.mutableConversationFilterList =  settings[@"mutableConversationFilterList"];

    return YES;
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

