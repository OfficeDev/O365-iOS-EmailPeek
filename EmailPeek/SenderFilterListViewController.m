/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "SenderFilterListViewController.h"

#import "SenderFilter.h"

@interface SenderFilterListViewController ()

// Track a mutable version internally even though we are exposing
// an immutable version publicly
@property (strong, nonatomic) NSMutableArray *mutableSenderFilterList;

@end

@implementation SenderFilterListViewController

#pragma mark - Lifecycle
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.isMovingFromParentViewController) {
        [self.delegate senderFilterListViewControllerDidComplete:self];
    }
}

#pragma mark - Properties
- (void)setSenderFilterList:(NSArray *)senderFilterList
{
    self.mutableSenderFilterList = [senderFilterList mutableCopy];

    [self.tableView reloadData];
}

- (NSArray *)senderFilterList
{
    return [self.mutableSenderFilterList copy];
}

- (NSMutableArray *)mutableSenderFilterList
{
    if (!_mutableSenderFilterList) {
        _mutableSenderFilterList = [[NSMutableArray alloc] init];
    }

    return _mutableSenderFilterList;
}

#pragma mark - Actions
- (IBAction)addSenderTapped
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Sender"
                                                                             message:@"Type the name and address of the sender you would like to follow."
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder               = @"John Doe";
        textField.spellCheckingType         = UITextSpellCheckingTypeNo;
        textField.autocapitalizationType    = UITextAutocapitalizationTypeWords;
        textField.autocorrectionType        = UITextAutocorrectionTypeNo;
    }];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder               = @"email@sample.com";
        textField.keyboardType              = UIKeyboardTypeEmailAddress;
        textField.spellCheckingType         = UITextSpellCheckingTypeNo;
        textField.autocapitalizationType    = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType        = UITextAutocorrectionTypeNo;
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:NULL];

    UIAlertAction *addAction    = [UIAlertAction actionWithTitle:@"Add"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             UITextField *nameField  = alertController.textFields[0];
                                                             UITextField *emailField = alertController.textFields[1];

                                                             [self addSenderWithName:nameField.text
                                                                             address:emailField.text];
                                                         }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:addAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:NULL];
}

- (void)addSenderWithName:(NSString *)name
                  address:(NSString *)address
{
    name    = [name    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    address = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (address.length == 0) {
        return;
    }

    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:self.mutableSenderFilterList.count
                                                      inSection:0];

    EmailAddress *emailAddress = [[EmailAddress alloc] initWithName:name
                                                            address:address];
    SenderFilter *newFilter    = [[SenderFilter alloc] initWithEmailAddress:emailAddress];

    [self.mutableSenderFilterList addObject:newFilter];

    [self.delegate senderFilterListViewController:self
                               didAddSenderFilter:newFilter];

    [self.tableView insertRowsAtIndexPaths:@[insertIndexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource
- (NSInteger)            tableView:(UITableView *)tableView
             numberOfRowsInSection:(NSInteger)section
{
    return self.mutableSenderFilterList.count;
}

- (UITableViewCell *)            tableView:(UITableView *)tableView
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"
                                                            forIndexPath:indexPath];

    SenderFilter *senderFilter = self.mutableSenderFilterList[indexPath.row];

    cell.textLabel.text       = senderFilter.emailAddress.name;
    cell.detailTextLabel.text = senderFilter.emailAddress.address;

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

    SenderFilter *senderFilter = [self.mutableSenderFilterList objectAtIndex:indexPath.row];
    
    [self.mutableSenderFilterList removeObjectAtIndex:indexPath.row];

    [self.delegate senderFilterListViewController:self
                            didRemoveSenderFilter:senderFilter];

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
