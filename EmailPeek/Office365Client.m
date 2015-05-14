/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "Office365Client.h"
#import "Office365ObjectTransformer.h"
#import "Message.h"
#import "MessageDetail.h"
#import <ADALiOS/ADAL.h>
#import <ADALiOS/ADKeychainTokenCacheStore.h>
#import <office365_odata_base/office365_odata_base.h>
#import <office365_discovery_sdk/office365_discovery_sdk.h>
#import <office365_exchange_sdk/office365_exchange_sdk.h>

// Notifications
NSString * const Office365ClientDidConnectNotification    = @"Office365ClientDidConnectNotification";
NSString * const Office365ClientDidDisconnectNotification = @"Office365ClientDidDisconnectNotification";

// Discovery URL
static NSString * const kDiscoveryResourceId       = @"https://api.office.com/discovery/";
static NSString * const kDiscoveryEndpoint         = @"https://api.office.com/discovery/v1.0/me/";

static NSString * const kOffice365ServiceDiscovery = @"Discovery";
static NSString * const kOffice365ServiceMail      = @"Mail";

static NSString * const kMessageFetchingSortOrder  = @"DateTimeReceived desc";
static const NSUInteger kMessageFetchingPageSize   = 50;

@interface Office365Client ()

@property (strong, nonatomic) NSURLSession *urlSession;

/**
 This object is responsible for converting from MSMailMessage instances to
 our domain objects of type Message.
 */
@property (strong, nonatomic) Office365ObjectTransformer *objectTransformer;


/**
 The authenticationContext keeps track of the tokenCacheStore which is what
 holds on to our authentication tokens.  It also knows how to acquire new tokens
 if necessary.
 */
@property (readonly, nonatomic) ADAuthenticationContext *authenticationContext;

/**
 This lookup cache has NSString keys which are the service names, and
 MSDiscoveryServiceInfo objects as values.  This is used to find the
 endpoints for connecting to services like 'Mail'.
 */
@property (copy, nonatomic) NSDictionary *serviceInfoLookupCache;

@end

@implementation Office365Client

@synthesize authenticationContext = _authenticationContext;

#pragma mark - Initialization
- (instancetype)init
{
    return [self initWithClientId:nil
                      redirectURL:nil
                     authorityURL:nil];
}

- (instancetype)initWithClientId:(NSString *)clientId
                     redirectURL:(NSURL *)redirectURL
                    authorityURL:(NSURL *)authorityURL
{
    self = [super init];

    if (self) {
        _clientId     = [clientId copy];
        _redirectURL  = redirectURL;
        _authorityURL = authorityURL;
    }

    return self;
}

#pragma mark - Properties
- (ADAuthenticationContext *)authenticationContext
{
    if (!_authenticationContext) {
        ADAuthenticationError *error;

        _authenticationContext = [ADAuthenticationContext authenticationContextWithAuthority:self.authorityURL.absoluteString
                                                                                       error:&error];

        
        
        if (!_authenticationContext) {
            NSLog(@"ERROR: Unable to create an authentication context. {%@}", [error localizedDescription]);
            NSLog(@"ERROR: Be sure that the authority is correct: '%@'", self.authorityURL);
        }

        // NOTE: The default token store uses a default keychain group.
        //
        // NOTE: We have to store this in an 'id' type
        id tokenCache = _authenticationContext.tokenCacheStore;

        if ([tokenCache isKindOfClass:[ADKeychainTokenCacheStore class]]) {
            [tokenCache setSharedGroup: nil];
        }
    }

    return _authenticationContext;
}

- (Office365ObjectTransformer *)objectTransformer
{
    if (!_objectTransformer) {
        _objectTransformer = [[Office365ObjectTransformer alloc] init];
    }

    return _objectTransformer;
}

- (NSURLSession *)urlSession
{
    if (!_urlSession) {
        _urlSession = [NSURLSession sharedSession];
    }

    return _urlSession;
}

- (NSNotificationCenter *)notificationCenter
{
    if (!_notificationCenter) {
        _notificationCenter = [NSNotificationCenter defaultCenter];
    }

    return _notificationCenter;
}

/**
  If we have a serviceInfoLookup dictionary, we know that we have connected
  successfully.  It is possible that the token is no longer valid, but the process
  of creating this lookup, meant that we had connected at some point.
 */
- (BOOL)isConnected
{
    return self.serviceInfoLookupCache != nil;
}

#pragma mark - Connect
- (void)connectWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    [self fetchServiceInfosWithCompletionHandler:^(NSDictionary *serviceInfoLookup, NSError *error) {
        if (completionHandler) {
            BOOL success = (serviceInfoLookup != nil);
            completionHandler(success, error);

            if (success) {
                [self.notificationCenter postNotificationName:Office365ClientDidConnectNotification
                                                       object:self];
            }
        }
    }];
}

- (void)disconnectWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
    ADAuthenticationError *error;
    [self.authenticationContext.tokenCacheStore removeAllWithError:&error];

    if (error) {
        NSLog(@"ERROR: Had trouble disconnecting, but will ignore it. {%@}", [error localizedDescription]);
    }

    // Remove all of the cookies from the session's cookie store.
    NSHTTPCookieStorage *cookieStore = self.urlSession.configuration.HTTPCookieStorage;

    for (NSHTTPCookie *cookie in cookieStore.cookies) {
        [cookieStore deleteCookie:cookie];
    }

    // Clear our local caches
    self.serviceInfoLookupCache = nil;

    if (completionHandler) {
        completionHandler(YES, nil);
    }

    [self.notificationCenter postNotificationName:Office365ClientDidDisconnectNotification
                                           object:self];
}

#pragma mark - Authentication
/**
 Performs async network request if there is not a valid token; if a valid token
 already exists in the cache, then it appears that no network request is performed.
 The completionHandler will always be called back regardless of success state.
 The `result.status` can be consulted to determine whether or not the call
 completed succesfully.
 
 If an error occurred, it will also be communicated via the result parameter.
 
 If this call to acquire the token is successful, the tokenStoreCache
 inside of the authenticationContext will be updated.
 
 Reasons for failure:
   - The user tapped "Cancel" on the prompt for username/password
   - There was no internet connection
   - The resourceId is not valid (not registered with the account)
   - Invalid username/password IS NOT transmitted as a failure; control still
     remains with the acquireToken...call.
 */
- (void)authenticateWithResourceId:(NSString *)resourceId
                 completionHandler:(void (^)(ADAuthenticationResult *result))completionHandler
{
    // NOTE: This line of code is responsible for putting the UIWebView on the
    //       screen which prompts for username/password
    [self.authenticationContext acquireTokenWithResource:resourceId
                                                clientId:self.clientId
                                             redirectUri:self.redirectURL
                                         completionBlock:^(ADAuthenticationResult *result) {
                                             completionHandler(result);
                                         }];
}

#pragma mark - Discovery
/**
  The discovery client acts as a middle man to detect what services are
  available for a given authenticated user.
 */
- (void)fetchDiscoveryClientWithCompletionHandler:(void (^)(MSDiscoveryClient *discoveryClient, NSError *error))completionHandler
{
    [self fetchClientForService:kOffice365ServiceDiscovery
              completionHandler:^(MSODataBaseContainer *client, NSError *error) {
                  completionHandler((MSDiscoveryClient *)client, error);
              }];
}

- (void)fetchServiceInfosWithCompletionHandler:(void (^)(NSDictionary *serviceInfoLookup, NSError *error))completionHandler
{
    if (self.serviceInfoLookupCache) {
        completionHandler(self.serviceInfoLookupCache, nil);

        return;
    }

    [self fetchDiscoveryClientWithCompletionHandler:^(MSDiscoveryClient *discoveryClient, NSError *error) {
        if (!discoveryClient) {
            completionHandler(nil, error);
            return;
        }

        MSDiscoveryServiceInfoCollectionFetcher *servicesInfoFetcher = [discoveryClient getservices];

        // Get back an array of MSDiscoveryServiceInfo objects
        // This is another async request
        NSURLSessionTask *servicesTask = [servicesInfoFetcher readWithCallback:^(NSArray *serviceInfos, MSODataException *error) {
            if (serviceInfos.count == 0 && error) {
                completionHandler(nil, error);
                return;
            }

            // NOTE: Not treating this as an error because it might be possible that
            //       there are not any service endpoints
            if (serviceInfos.count == 0) {
                NSLog(@"WARNING: There are no service endpoints for the authenticated user.");
            }

            NSMutableDictionary *serviceInfoLookup = [[NSMutableDictionary alloc] init];

            // Here is where we gather the service URLs returned by the Discovery Service. You may not
            // need to call the Discovery Service again until either this cache is removed, or you
            // get an error that indicates that the endpoint is no longer valid.
            for (MSDiscoveryServiceInfo *serviceInfo in serviceInfos) {
                serviceInfoLookup[serviceInfo.capability] = serviceInfo;
            }

            self.serviceInfoLookupCache = serviceInfoLookup;

            completionHandler([serviceInfoLookup copy], nil);
        }];

        [servicesTask resume];
    }];
}

#pragma mark - Mail
- (void)fetchOutlookClientWithCompletionHandler:(void (^)(MSOutlookClient *outlookClient, NSError *error))completionHandler
{
    [self fetchClientForService:kOffice365ServiceMail
              completionHandler:^(MSODataBaseContainer *client, NSError *error) {
                  completionHandler((MSOutlookClient *)client, error);
              }];
}

#pragma mark Fetching
/**
 Completion handler will be called async in a thread other than main.  If it is
 successful, the messages array will be non nil.  If it fails, messages will be nil,
 at which time it is acceptable to look at the error parameter.
 
 The messages set will contain objects of type Message.
*/
- (void)fetchMessagesFromDate:(NSDate *)fromDate
                   withFilter:(NSString *)filter
            completionHandler:(void (^)(NSSet *messages, NSError *error))completionHandler
{
    NSString *adjustedFilter = filter;

    if (fromDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd'T'HH:mm:ssZZZZZ";

        NSString *fromDateFilter = [NSString stringWithFormat:@"DateTimeReceived gt %@", [dateFormatter stringFromDate:fromDate]];

        adjustedFilter = [NSString stringWithFormat:@"(%@) and (%@)", fromDateFilter, filter];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger            currentPage = 0;
        NSMutableSet         *allMessages = [[NSMutableSet alloc] init];
        dispatch_semaphore_t  semaphore   = dispatch_semaphore_create(0);

        // This infinite loop is present because we are fetching the next page
        // until we either get an error, or we fetch a page that is not full.
        // Getting out of this loop is done explicitly in both of those cases
        // via the "return" lines below.
        while (true) {
            __block NSArray *currentPageMessages;
            __block NSError *currentPageError;

            [self fetchMessagesForPageNumber:currentPage
                                    pageSize:kMessageFetchingPageSize
                                      filter:adjustedFilter
                                     orderBy:kMessageFetchingSortOrder
                           completionHandler:^(NSArray *messages, NSError *error) {
                               currentPageMessages = messages;
                               currentPageError    = error;

                               dispatch_semaphore_signal(semaphore);
                           }];

            // This line block until the page requested returns
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

            if (!currentPageMessages) {
                // NOTE: We are making the decision that if one page load fails,
                //       the whole thing fails.
                completionHandler(nil, currentPageError);
                return;
            }

            // NOTE: Messages may have come in while we were fetching pages, making it possible
            //       for us to have duplicates.  This is why we are using a set.
            [allMessages addObjectsFromArray:currentPageMessages];

            if (currentPageMessages.count < kMessageFetchingPageSize) {
                completionHandler(allMessages, nil);
                return;
            }
            
            currentPage++;
        }
    });
}

- (void)fetchMessagesForPageNumber:(NSUInteger)pageNumber
                          pageSize:(NSUInteger)pageSize
                            filter:(NSString *)filter
                           orderBy:(NSString *)orderBy
                 completionHandler:(void (^)(NSArray *messages, NSError *error))completionHandler
{
    NSLog(@"INFO: Fetching messages on page %lu", (unsigned long)pageNumber);

    [self fetchOutlookClientWithCompletionHandler:^(MSOutlookClient *outlookClient, NSError *error) {
        if (!outlookClient) {
            completionHandler(nil, error);
            return;
        }

        // NOTE: The call to 'getMessages' will go to the 'Inbox' by default
        MSOutlookUserFetcher              *userFetcher              = [outlookClient getMe];
        MSOutlookMessageCollectionFetcher *messageCollectionFetcher = [userFetcher getMessages];

        [messageCollectionFetcher select:[self.objectTransformer outlookMessageFieldsForMessage]];
        [messageCollectionFetcher filter:filter];
        [messageCollectionFetcher orderBy:orderBy];
        [messageCollectionFetcher top:(int)pageSize];
        [messageCollectionFetcher skip:(int)(pageNumber * pageSize)];

        // Network request
        NSURLSessionTask *task = [messageCollectionFetcher readWithCallback:^(NSArray *outlookMessages, MSODataException *error) {
            NSArray *transformedMessages = [self.objectTransformer messagesFromOutlookMessages:outlookMessages];
            
            completionHandler(transformedMessages, error);
        }];
        
        [task resume];
    }];
}

- (void)fetchMessageDetailForMessage:(Message *)message
                   completionHandler:(void (^)(MessageDetail *, NSError *))completionHandler
{
    if (!message || !message.guid) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:             NSLocalizedString(@"Cannot fetch message detail.", nil),
                                   NSLocalizedFailureReasonErrorKey:      NSLocalizedString(@"Supplied message does not have a valid message id.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Confirm that a non nil object is being provided.", nil)};

        completionHandler(nil, [NSError errorWithDomain:@"Office365"
                                                   code:-1
                                               userInfo:userInfo]);
        return;
    }

    [self fetchOutlookClientWithCompletionHandler:^(MSOutlookClient *outlookClient, NSError *error) {
        if (!outlookClient) {
            completionHandler(nil, error);
            return;
        }

        MSOutlookUserFetcher              *userFetcher              = [outlookClient getMe];
        MSOutlookMessageCollectionFetcher *messageCollectionFetcher = [userFetcher getMessages];
        MSOutlookMessageFetcher           *messageFetcher           = [messageCollectionFetcher getById:message.guid];

        [messageFetcher select:[self.objectTransformer outlookMessageFieldsForMessageDetail]];
        [messageFetcher expand:@"Attachments"];

        NSURLSessionTask *task = [messageFetcher readWithCallback:^(MSOutlookMessage *outlookMessage, MSODataException *error) {
            MessageDetail *messageDetail = [self.objectTransformer messageDetailFromOutlookMessage:outlookMessage];

            completionHandler(messageDetail, error);
        }];

        [task resume];
    }];
}

#pragma mark Replying
- (void)replyToMessage:(Message *)message
              replyAll:(BOOL)replyAll
          responseBody:(NSString *)responseBody
     completionHandler:(void (^)(BOOL, NSError *))completionHandler
{
    if (!message || !message.guid) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:             NSLocalizedString(@"Cannot reply to message.", nil),
                                   NSLocalizedFailureReasonErrorKey:      NSLocalizedString(@"Supplied message does not have a valid message id.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Confirm that a non nil object is being provided.", nil)};

        completionHandler(NO, [NSError errorWithDomain:@"Office365"
                                                  code:-1
                                              userInfo:userInfo]);
        return;
    }

    [self fetchOutlookClientWithCompletionHandler:^(MSOutlookClient *outlookClient, NSError *error) {
        if (!outlookClient) {
            completionHandler(NO, error);
            return;
        }

        MSOutlookUserFetcher              *userFetcher              = [outlookClient getMe];
        MSOutlookMessageCollectionFetcher *messageCollectionFetcher = [userFetcher getMessages];
        MSOutlookMessageFetcher           *messageFetcher           = [messageCollectionFetcher getById:message.guid];
        MSOutlookMessageOperations        *messageOperations        = [messageFetcher operations];

        NSURLSessionTask *task;

        if (replyAll) {
            task = [messageOperations replyAllWithComment:responseBody
                                                 callback:^(int returnValue, MSODataException *error) {
                                                     BOOL success = (returnValue == 0);

                                                     completionHandler(success, error);
                                                 }];
        }
        else {
            task = [messageOperations replyAllWithComment:responseBody
                                                 callback:^(int returnValue, MSODataException *error) {
                                                     BOOL success = (returnValue == 0);

                                                     completionHandler(success, error);
                                                 }];
        }

        [task resume];
    }];
}

#pragma mark Updates
- (void)      markMessage:(Message *)message
                   isRead:(BOOL)isRead
        updateOutlookFlag:(BOOL)updateOutlookFlag
        completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler
{
    if (updateOutlookFlag) {
        if (message.isReadOnServer == isRead) {
            completionHandler(message, nil);
            return;
        }

        [self updateMessage:message
                withPayload:@{@"IsRead" : @(isRead)}
          completionHandler:completionHandler];
    }
    else {
        if (message.isReadOnClient == isRead) {
            completionHandler(message, nil);
            return;
        }

        if (isRead) {
            [self addCategory:MessageCategoryIsReadOnClient
                    toMessage:message
            completionHandler:completionHandler];
        }
        else {
            [self removeCategory:MessageCategoryIsReadOnClient
                     fromMessage:message
               completionHandler:completionHandler];
        }
    }
}

- (void)      markMessage:(Message *)message
                 isHidden:(BOOL)isHidden
        completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler
{
    if (isHidden) {
        [self addCategory:MessageCategoryIsHiddenOnClient
                toMessage:message
        completionHandler:completionHandler];
    }
    else {
        [self removeCategory:MessageCategoryIsHiddenOnClient
                 fromMessage:message
           completionHandler:completionHandler];
    }
}

- (void)      addCategory:(NSString *)category
                toMessage:(Message *)message
        completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler
{
    if ([message.categories containsObject:category]) {
        // There is nothing to do because the category already exists, but this
        // is not a "failure", so just respond with the same message provided
        completionHandler(message, nil);

        return;
    }

    NSArray      *newCategories = [@[category] arrayByAddingObjectsFromArray:message.categories];
    NSDictionary *payload       = @{@"Categories" : newCategories};

    [self updateMessage:message
            withPayload:payload
      completionHandler:completionHandler];
}

- (void)   removeCategory:(NSString *)category
              fromMessage:(Message *)message
        completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler
{
    if (![message.categories containsObject:category]) {
        // There is nothing to do because the category doesn't exist to remove,
        // but this is not a "failure", so just respond with the same message provided
        completionHandler(message, nil);

        return;
    }

    NSMutableArray *newCategories = [message.categories mutableCopy];

    [newCategories removeObject:category];

    NSDictionary *payload = @{@"Categories" : newCategories};

    [self updateMessage:message
            withPayload:payload
      completionHandler:completionHandler];
}

- (void)updateMessage:(Message *)message
          withPayload:(id)updatePayload
    completionHandler:(void (^)(Message *updatedMessage, NSError *error))completionHandler
{
    if (!message || !message.guid) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:             NSLocalizedString(@"Cannot update message.", nil),
                                   NSLocalizedFailureReasonErrorKey:      NSLocalizedString(@"Supplied message does not have a valid message id.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Confirm that a non nil object is being provided.", nil)};

        completionHandler(nil, [NSError errorWithDomain:@"Office365"
                                                   code:-1
                                               userInfo:userInfo]);
        return;
    }

    if (!updatePayload) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:             NSLocalizedString(@"Cannot update message.", nil),
                                   NSLocalizedFailureReasonErrorKey:      NSLocalizedString(@"Payload supplied is invalid.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Confirm that a non nil payload is being provided.", nil)};

        completionHandler(nil, [NSError errorWithDomain:@"Office365"
                                                   code:-1
                                               userInfo:userInfo]);
    }

    NSError *error;
    NSData  *jsonPayload = [NSJSONSerialization dataWithJSONObject:updatePayload
                                                           options:0
                                                             error:&error];

    if (!jsonPayload) {
        completionHandler(nil, error);
        return;
    }

    NSString *jsonPayloadAsString = [[NSString alloc] initWithData:jsonPayload
                                                          encoding:NSUTF8StringEncoding];

    [self fetchOutlookClientWithCompletionHandler:^(MSOutlookClient *outlookClient, NSError *error) {
        if (!outlookClient) {
            completionHandler(nil, error);
            return;
        }

        MSOutlookUserFetcher              *userFetcher              = [outlookClient getMe];
        MSOutlookMessageCollectionFetcher *messageCollectionFetcher = [userFetcher getMessages];
        MSOutlookMessageFetcher           *messageFetcher           = [messageCollectionFetcher getById:message.guid];

        [messageFetcher select:self.objectTransformer.outlookMessageFieldsForMessage];

        // NOTE: updateRaw is used to perform single field updates on the server - Office365 iOS SDK version 0.8.3.
        // Asynchronous network request
        NSURLSessionTask *task = [messageFetcher updateRaw:jsonPayloadAsString
                                                callback:^(NSString *response, MSODataException *error) {
                                                              if (!response) {
                                                                  completionHandler(nil, error);
                                                                  return;
                                                              }

                                                              NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];

                                                              id<MSODataDependencyResolver> resolver       = [messageFetcher resolver];
                                                              id<MSODataJsonSerializer>     jsonSerializer = [resolver jsonSerializer];

                                                              MSOutlookMessage *updatedOutlookMessage = [jsonSerializer deserialize:responseData
                                                                                                                                    asClass:[MSOutlookMessage class]];

                                                              Message *message = [self.objectTransformer messageFromOutlookMessage:updatedOutlookMessage];

                                                              completionHandler(message, error);
                                                          }];
        
        [task resume];
    }];
}


#pragma mark - Synchronous service related helpers
- (NSString *)resourceIdForService:(NSString *)serviceName
{
    if ([serviceName isEqualToString:kOffice365ServiceDiscovery]) {
        return kDiscoveryResourceId;
    }

    return [self.serviceInfoLookupCache[serviceName] serviceResourceId];
}

- (NSString *)endpointForService:(NSString *)serviceName
{
    if ([serviceName isEqualToString:kOffice365ServiceDiscovery]) {
        return kDiscoveryEndpoint;
    }

    return [self.serviceInfoLookupCache[serviceName] serviceEndpointUri];
}

- (Class)clientClassForService:(NSString *)serviceName
{
    if ([serviceName isEqualToString:kOffice365ServiceDiscovery]) { return [MSDiscoveryClient class]; }
    if ([serviceName isEqualToString:kOffice365ServiceMail]     ) { return [MSOutlookClient   class]; }

    return nil;
}

#pragma mark Asynchronous service related helpers
/**
 Will create a new service client every time.  Network hit
 is not always incurred if there is a valid token in the authenticationContext.
 */
- (void)fetchClientForService:(NSString *)serviceName
            completionHandler:(void (^)(MSODataBaseContainer *client, NSError *error))completionHandler
{
    NSString *resourceId      = [self resourceIdForService:serviceName];
    NSString *serviceEndpoint = [self endpointForService:serviceName];
    Class     clientClass     = [self clientClassForService:serviceName];

    // If we can't find these things, it is likely due to the fact that we haven't
    // run the discovery
    if (!resourceId || !serviceEndpoint || !clientClass) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:             NSLocalizedString(@"Cannot create service client.", nil),
                                   NSLocalizedFailureReasonErrorKey:      NSLocalizedString(@"Service endpoints could not be found.", nil),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Consider reconnecting.", nil)};

        completionHandler(nil, [NSError errorWithDomain:@"Office365"
                                                   code:-1
                                               userInfo:userInfo]);
        return;
    }

    // Potentially issues a network request
    [self authenticateWithResourceId:resourceId
                   completionHandler:^(ADAuthenticationResult *result) {
                       if (result.status != AD_SUCCEEDED) {
                           completionHandler(nil, result.error);
                           return;
                       }

                       // NOTE: The dependencyResolver is needed because it is required to be passed along
                       //       to the MSODataBaseContainer's initializers
                       ADALDependencyResolver *dependencyResolver = [[ADALDependencyResolver alloc] initWithContext:self.authenticationContext
                                                                                                         resourceId:resourceId
                                                                                                           clientId:self.clientId
                                                                                                        redirectUri:self.redirectURL];

                       MSODataBaseContainer   *serviceClient      = [[clientClass alloc] initWithUrl:serviceEndpoint
                                                                                  dependencyResolver:dependencyResolver];

                       completionHandler(serviceClient, nil);
                   }];
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

