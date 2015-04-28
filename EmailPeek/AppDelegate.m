/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "AppDelegate.h"

#import "UIColor+Office365.h"
#import "Office365Client.h"
#import "SettingsManager.h"
#import "ConversationManager.h"

#import "ConversationListViewController.h"
#import "MessageViewController.h"

// You will set your application's clientId and redirect URI. You get
// these when you register your application in Azure AD.
static NSString * const kClientId           = @"ENTER_REDIRECT_URI_HERE";
static NSString * const kRedirectURLString  = @"ENTER_CLIENT_ID_HERE";
static NSString * const kAuthorityURLString = @"https://login.microsoftonline.com/common";

@interface AppDelegate () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UIApplication       *application;
@property (strong, nonatomic) Office365Client     *office365Client;
@property (strong, nonatomic) SettingsManager     *settingsManager;
@property (strong, nonatomic) ConversationManager *conversationManager;

@end

@implementation AppDelegate

- (BOOL)                  application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.tintColor = [UIColor o365_primaryColor];

    self.application = application;

    self.settingsManager = [[SettingsManager alloc] init];
    [self.settingsManager reload];

    self.office365Client = [[Office365Client alloc] initWithClientId:kClientId
                                                         redirectURL:[NSURL URLWithString:kRedirectURLString]
                                                        authorityURL:[NSURL URLWithString:kAuthorityURLString]];

    self.conversationManager = [[ConversationManager alloc] init];
    self.conversationManager.office365Client = self.office365Client;
    self.conversationManager.settingsManager = self.settingsManager;
    self.conversationManager.application     = application;

    // Pull out the starting view controllers to configure them
    UISplitViewController          *splitVC            = (UISplitViewController *)self.window.rootViewController;
    UINavigationController         *navigationVC       = splitVC.viewControllers[0];
    ConversationListViewController *conversationListVC = navigationVC.viewControllers[0];

    // Configure the split view controller
    splitVC.delegate = self;
    splitVC.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

    // Pass the context to the starting view controller
    conversationListVC.conversationManager = self.conversationManager;
    NSNotificationCenter *notificationCenter = self.conversationManager.notificationCenter;
    [notificationCenter addObserver:self
                           selector:@selector(allConversationsDidChange:)
                               name:ConversationManagerAllConversationsDidChangeNotification
                             object:self.conversationManager];

    [self registerForLocalNotifications];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.office365Client.isConnected) {
        [self.conversationManager refreshAllConversations];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.settingsManager save];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSNotificationCenter *notificationCenter = self.conversationManager.notificationCenter;
    
    [notificationCenter removeObserver:self
                                  name:ConversationManagerAllConversationsDidChangeNotification
                                object:self.conversationManager];
}

#pragma mark - UISplitViewControllerDelegate
- (BOOL)            splitViewController:(UISplitViewController *)splitViewController
        collapseSecondaryViewController:(UIViewController *)secondaryViewController
              ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    if (![secondaryViewController isKindOfClass:[UINavigationController class]]) {
        return NO;
    }

    UINavigationController *navigationVC = (UINavigationController *)secondaryViewController;

    if (![navigationVC.viewControllers[0] isKindOfClass:[MessageViewController class]]) {
        return NO;
    }

    MessageViewController *messageVC = navigationVC.viewControllers[0];

    if (!messageVC.message) {
        return YES;
    }

    return NO;
}

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc
{
    if (svc.displayMode == UISplitViewControllerDisplayModePrimaryHidden) {
        return UISplitViewControllerDisplayModeAllVisible;
    }
    else {
        return UISplitViewControllerDisplayModePrimaryHidden;
    }
}

#pragma mark - Local Notifications
- (void)registerForLocalNotifications
{
    UIUserNotificationType      notificationTypes    = UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeAlert |
                                                       UIUserNotificationTypeSound;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes
                                                                                         categories:nil];

    [self.application registerUserNotificationSettings:notificationSettings];
}

- (void)updateIconBadgeCount:(NSUInteger)iconBadgeCount
{
    UIUserNotificationSettings *notificationSettings = self.application.currentUserNotificationSettings;

    if (notificationSettings.types & UIUserNotificationTypeBadge) {
        self.application.applicationIconBadgeNumber = iconBadgeCount;
    }
}

- (void)sendLocalNotificationWithTitle:(NSString *)title
                                  body:(NSString *)body
{
    UIUserNotificationSettings *notificationSettings = self.application.currentUserNotificationSettings;

    if (notificationSettings.types & UIUserNotificationTypeAlert) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];

        localNotification.alertBody  = body;
        localNotification.soundName  = UILocalNotificationDefaultSoundName;

        [self.application presentLocalNotificationNow:localNotification];
    }
}

#pragma mark - Notification Center
- (void)addRefreshNotificationObservers
{
    NSNotificationCenter *notificationCenter = self.conversationManager.notificationCenter;

    [notificationCenter addObserver:self
                           selector:@selector(allConversationsRefreshDidEnd:)
                               name:ConversationManagerAllConversationsRefreshDidEndNotification
                             object:self.conversationManager];

    [notificationCenter addObserver:self
                           selector:@selector(allConversationsRefreshDidFail:)
                               name:ConversationManagerAllConversationsRefreshDidFailNotification
                             object:self.conversationManager];
}

- (void)removeRefreshNotificationObservers
{
    NSNotificationCenter *notificationCenter = self.conversationManager.notificationCenter;

    [notificationCenter removeObserver:self
                                  name:ConversationManagerAllConversationsRefreshDidEndNotification
                                object:self.conversationManager];

    [notificationCenter removeObserver:self
                                  name:ConversationManagerAllConversationsRefreshDidFailNotification
                                object:self.conversationManager];
}

- (void)allConversationsDidChange:(NSNotification *)notification
{
    NSUInteger unreadCount = [notification.userInfo[ConversationManagerAllConversationsUnreadMessageCountKey] unsignedIntegerValue];

    [self updateIconBadgeCount:unreadCount];
}

- (void)allConversationsRefreshDidEnd:(NSNotification *)notification
{
    [self sendLocalNotificationWithTitle:@"Updated Messages"
                                    body:@"Your message list has been refreshed"];

    [self removeRefreshNotificationObservers];

}

- (void)allConversationsRefreshDidFail:(NSNotification *)notification
{
    [self removeRefreshNotificationObservers];
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
