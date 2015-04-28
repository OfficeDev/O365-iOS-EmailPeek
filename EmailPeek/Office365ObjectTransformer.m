/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "Office365ObjectTransformer.h"

#import "Message.h"
#import "MessageDetail.h"
#import "MessageAttachment.h"

#import "MSOutlookServicesMessage.h"
#import "MSOutlookServicesItemBody.h"
#import "MSOutlookServicesRecipient.h"
#import "MSOutlookServicesEmailAddress.h"
#import "MSOutlookServicesAttachment.h"

NSString * const MessageCategoryIsReadOnClient   = @"EmailPeek - Read";
NSString * const MessageCategoryIsHiddenOnClient = @"EmailPeek - Hidden";

@implementation Office365ObjectTransformer

// Convert from MSOutlookServicesMessage to Message
#pragma mark - Message
// Ignored fields
//   * $$__ODataType
//   * From
//   * BccRecipients
//   * ReplyTo
//   * DateTimeSent
//   * IsDeliveryReceiptRequested
//   * IsReadReceiptRequested
//   * IsDraft
//   * ParentFolderId
//   * ChangeKey
//   * DateTimeCreated
//   * DateTimeLastModified
- (NSString *)outlookMessageFieldsForMessage
{
    return [@[@"Id",
              @"ConversationId",
              @"Subject",
              @"Sender",
              @"ToRecipients",
              @"CcRecipients",
              @"BodyPreview",
              @"DateTimeReceived",
              @"IsRead",
              @"HasAttachments",
              @"Importance",
              @"Categories"] componentsJoinedByString:@","];
}

- (Message *)messageFromOutlookMessage:(MSOutlookServicesMessage *)outlookMessage
{
    if (!outlookMessage) {
        return nil;
    }

    return [[Message alloc] initWithGUID:outlookMessage.Id
                        conversationGUID:outlookMessage.ConversationId
                                 subject:outlookMessage.Subject
                                  sender:[self emailAddressFromOutlookRecipient:outlookMessage.Sender]
                            toRecipients:[self emailAddressesFromOutlookRecipients:outlookMessage.ToRecipients]
                            ccRecipients:[self emailAddressesFromOutlookRecipients:outlookMessage.CcRecipients]
                             bodyPreview:outlookMessage.BodyPreview
                            dateReceived:outlookMessage.DateTimeReceived
                          isReadOnServer:outlookMessage.IsRead
                          isReadOnClient:[outlookMessage.Categories containsObject:MessageCategoryIsReadOnClient]
                                isHidden:[outlookMessage.Categories containsObject:MessageCategoryIsHiddenOnClient]
                          hasAttachments:outlookMessage.HasAttachments
                              importance:[self messageImportanceFromOutlookImportance:outlookMessage.Importance]
                              categories:outlookMessage.Categories];
}

- (NSArray *)messagesFromOutlookMessages:(NSArray *)outlookMessages
{
    if (!outlookMessages) {
        return nil;
    }

    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:outlookMessages.count];

    for (MSOutlookServicesMessage *outlookMessage in outlookMessages) {
        [messages addObject:[self messageFromOutlookMessage:outlookMessage]];
    }

    return [messages copy];
}

#pragma mark - MessageDetail
// Ignored fields
//   * Body.$$__ODataType
//   * UniqueBody.$$__ODataType
- (NSString *)outlookMessageFieldsForMessageDetail
{
    return [@[@"Id",
              @"Body",
              @"UniqueBody",
              @"Attachments"] componentsJoinedByString:@","];
}

- (MessageDetail *)messageDetailFromOutlookMessage:(MSOutlookServicesMessage *)outlookMessage
{
    if (!outlookMessage) {
        return nil;
    }

    return [[MessageDetail alloc] initWithGUID:outlookMessage.Id
                                          body:outlookMessage.Body.Content
                                    isBodyHTML:outlookMessage.Body.ContentType == MSOutlookServices_BodyType_HTML
                                    uniqueBody:outlookMessage.UniqueBody.Content
                              isUniqueBodyHTML:outlookMessage.UniqueBody.ContentType == MSOutlookServices_BodyType_HTML
                                   attachments:[self messageAttachmentsFromOutlookAttachments:outlookMessage.Attachments]];
}


#pragma mark - MessageImportance
- (MessageImportance)messageImportanceFromOutlookImportance:(MSOutlookServicesImportance)outlookImportance
{
    MessageImportance importance;

    switch (outlookImportance) {
        case MSOutlookServices_Importance_Low:
            importance = MessageImportanceLow;
            break;
        case MSOutlookServices_Importance_Normal:
            importance = MessageImportanceNormal;
            break;
        case MSOutlookServices_Importance_High:
            importance = MessageImportanceHigh;
            break;
    }

    return importance;
}


#pragma mark - EmailAddress
// Ignored fields
//   * $$__ODataType
//   * EmailAddress.$$__ODataType
- (EmailAddress *)emailAddressFromOutlookRecipient:(MSOutlookServicesRecipient *)outlookRecipient
{
    if (!outlookRecipient) {
        return nil;
    }

    return [[EmailAddress alloc] initWithName:outlookRecipient.EmailAddress.Name
                                      address:outlookRecipient.EmailAddress.Address];
}

- (NSArray *)emailAddressesFromOutlookRecipients:(NSArray *)outlookRecipients
{
    if (!outlookRecipients) {
        return nil;
    }

    NSMutableArray *emailAddresses = [[NSMutableArray alloc] initWithCapacity:outlookRecipients.count];

    for (MSOutlookServicesRecipient *outlookRecipient in outlookRecipients) {
        [emailAddresses addObject:[self emailAddressFromOutlookRecipient:outlookRecipient]];
    }

    return [emailAddresses copy];
}


#pragma mark - Attachment
// Ignored fields
//   * $$__ODataType;
//   * IsInline
//   * DateTimeLastModified
- (MessageAttachment *)messageAttachmentFromOutlookAttachment:(MSOutlookServicesAttachment *)outlookAttachment
{
    if (!outlookAttachment) {
        return nil;
    }

    return [[MessageAttachment alloc] initWithGUID:outlookAttachment.Id
                                              name:outlookAttachment.Name
                                       contentType:outlookAttachment.ContentType
                                         byteCount:(NSUInteger)outlookAttachment.Size];
}

- (NSArray *)messageAttachmentsFromOutlookAttachments:(NSArray *)outlookAttachments
{
    if (!outlookAttachments) {
        return nil;
    }

    NSMutableArray *attachments = [[NSMutableArray alloc] initWithCapacity:outlookAttachments.count];

    for (MSOutlookServicesAttachment *outlookAttachment in outlookAttachments) {
        [attachments addObject:[self messageAttachmentFromOutlookAttachment:outlookAttachment]];
    }

    return [attachments copy];
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

