/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import <Foundation/Foundation.h>

@class Message;
@class MessageDetail;

extern NSString * const Office365ClientDidConnectNotification;
extern NSString * const Office365ClientDidDisconnectNotification;


// The main class that talks to Office 365 and performs operations in Outlook
@interface Office365Client : NSObject

// Dependencies
@property (strong,   nonatomic) NSNotificationCenter *notificationCenter;

// App specific credentials provided by Azure when registering the app
@property (readonly, nonatomic) NSString     *clientId;
@property (readonly, nonatomic) NSURL        *redirectURL;
@property (readonly, nonatomic) NSURL        *authorityURL;

// Convenience
@property (readonly, nonatomic) BOOL          isConnected;

- (instancetype)initWithClientId:(NSString *)clientId
                     redirectURL:(NSURL *)redirectURL
                    authorityURL:(NSURL *)authorityURL;

// Connect and disconnect from Office 365
- (void)connectWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;
- (void)disconnectWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

// Perform mail operations in Outlook
- (void)fetchMessagesFromDate:(NSDate *)fromDate
                   withFilter:(NSString *)filter
            completionHandler:(void (^)(NSSet *messages, NSError *error))completionHandler;

- (void)fetchMessageDetailForMessage:(Message *)message
                   completionHandler:(void (^)(MessageDetail *messageDetail, NSError *error))completionHandler;

- (void)replyToMessage:(Message *)message
              replyAll:(BOOL)replyAll
          responseBody:(NSString *)responseBody
     completionHandler:(void (^)(BOOL success, NSError *error))completionHandler;

- (void)      markMessage:(Message *)message
                   isRead:(BOOL)isRead
        updateOutlookFlag:(BOOL)updateOutlookFlag
        completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler;

- (void)      markMessage:(Message *)message
                 isHidden:(BOOL)isHidden
        completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler;

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

