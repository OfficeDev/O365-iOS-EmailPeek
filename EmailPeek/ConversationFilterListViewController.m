/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "ConversationFilterListViewController.h"
#import "ConversationFilter.h"

@interface ConversationFilterListViewController ()

@property (strong, nonatomic) NSMutableArray *mutableConversationFilterList;

@end

@implementation ConversationFilterListViewController

#pragma mark - Lifecycle
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.isMovingFromParentViewController) {
        [self.delegate conversationFilterListViewControllerDidComplete:self];
    }
}

#pragma mark - Properties
- (void)setConversationFilterList:(NSArray *)conversationFilterList
{
    self.mutableConversationFilterList = [conversationFilterList mutableCopy];

    [self.tableView reloadData];
}

- (NSArray *)conversationFilterList
{
    return [self.mutableConversationFilterList copy];
}

- (NSMutableArray *)mutableConversationFilterList
{
    if (!_mutableConversationFilterList) {
        _mutableConversationFilterList = [[NSMutableArray alloc] init];
    }

    return _mutableConversationFilterList;
}


#pragma mark - Actions
- (IBAction)infoButtonTapped:(UIBarButtonItem *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Following a Conversation"
                                                                             message:@"Indicate that you would like to follow a conversation by tapping the button when viewing a message."
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:NULL];

    [alertController addAction:okAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:NULL];
}


#pragma mark - UITableViewDataSource
- (NSInteger)            tableView:(UITableView *)tableView
             numberOfRowsInSection:(NSInteger)section
{
    return self.mutableConversationFilterList.count;
}

- (UITableViewCell *)            tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];

    ConversationFilter *conversationFilter = self.mutableConversationFilterList[indexPath.row];

    cell.textLabel.text = conversationFilter.conversationSubject;

    return cell;
}

- (BOOL)            tableView:(UITableView *)tableView
        canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)         tableView:(UITableView *)tableView
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
         forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    ConversationFilter *conversationFilter = self.mutableConversationFilterList[indexPath.row];

    [self.mutableConversationFilterList removeObjectAtIndex:indexPath.row];

    [self.delegate conversationFilterListViewController:self
                            didRemoveConversationFilter:conversationFilter];
    
    [tableView deleteRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
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
