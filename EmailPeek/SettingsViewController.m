/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See full license at the bottom of this file.
 */

#import "SettingsViewController.h"

#import "UIColor+Office365.h"
#import "SettingsManager.h"

#import "SenderFilterListViewController.h"
#import "ConversationFilterListViewController.h"

@interface SettingsViewController () <SenderFilterListViewControllerDelegate, ConversationFilterListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch        *updateServerSideReadStatusSwitch;

@property (weak, nonatomic) IBOutlet UIStepper       *includeDaysBackStepper;
@property (weak, nonatomic) IBOutlet UILabel         *includeDaysBackLabel;
@property (weak, nonatomic) IBOutlet UISwitch        *includeUrgentSwitch;
@property (weak, nonatomic) IBOutlet UISwitch        *includeUnreadSwitch;

@property (weak, nonatomic) IBOutlet UIView          *includeSendersCountView;
@property (weak, nonatomic) IBOutlet UILabel         *includeSendersCountLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *includeSendersCell;

@property (weak, nonatomic) IBOutlet UIView          *includeConversationsCountView;
@property (weak, nonatomic) IBOutlet UILabel         *includeConversationsCountLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *includeConversationsCell;

@end

@implementation SettingsViewController

#pragma mark - Properties
- (void)setSettingsManager:(SettingsManager *)settingsManager
{
    _settingsManager = settingsManager;

    [self updateUI];
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupUI];
    [self updateUI];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSenderFilterList"]) {
        SenderFilterListViewController *senderFilterListVC = segue.destinationViewController;

        senderFilterListVC.delegate         = self;
        senderFilterListVC.senderFilterList = self.settingsManager.senderFilterList;
    }
    else if ([segue.identifier isEqualToString:@"showConversationFilterList"]) {
        ConversationFilterListViewController *conversationFilterListVC = segue.destinationViewController;

        conversationFilterListVC.delegate               = self;
        conversationFilterListVC.conversationFilterList = self.settingsManager.conversationFilterList;
    }
}

#pragma mark - UI Setup/Update
- (void)setupUI
{
    self.includeSendersCountView.backgroundColor          = [UIColor o365_primaryColor];
    self.includeSendersCountView.layer.cornerRadius       = CGRectGetHeight(self.includeSendersCountView.bounds) / 2.0;

    self.includeConversationsCountView.backgroundColor    = [UIColor o365_primaryColor];
    self.includeConversationsCountView.layer.cornerRadius = CGRectGetHeight(self.includeConversationsCountView.bounds) / 2.0;

    self.includeSendersCell.selectedBackgroundView                       = [[UIView alloc] init];
    self.includeSendersCell.selectedBackgroundView.backgroundColor       = [UIColor o365_primaryHighlightColor];

    self.includeConversationsCell.selectedBackgroundView                 = [[UIView alloc] init];
    self.includeConversationsCell.selectedBackgroundView.backgroundColor = [UIColor o365_primaryHighlightColor];
}

- (void)updateUI
{
    [self updateSwitches];
    [self updateFilterCountLabels];
    [self updateIncludeDaysBackLabel];
}

- (void)updateSwitches
{
    self.updateServerSideReadStatusSwitch.on = self.settingsManager.updateServerSideReadStatus;

    self.includeUrgentSwitch.on              = self.settingsManager.includeUrgentMessages;
    self.includeUnreadSwitch.on              = self.settingsManager.includeUnreadMessages;
}

- (void)updateIncludeDaysBackLabel
{
    NSUInteger  daysBackValue = self.settingsManager.daysBackToConsider;
    NSString   *days          = (daysBackValue > 1) ? @"days" : @"day";

    self.includeDaysBackStepper.value = daysBackValue;
    self.includeDaysBackLabel.text    = [NSString stringWithFormat:@"Last %lu %@", (long unsigned)daysBackValue, days];
}

- (void)updateFilterCountLabels
{
    self.includeSendersCountLabel.text       = [NSString stringWithFormat:@"%lu", (unsigned long)self.settingsManager.senderFilterList.count];
    self.includeConversationsCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.settingsManager.conversationFilterList.count];
}


#pragma mark - Actions
- (IBAction)disconnectTapped:(UIButton *)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure you want to disconnect?"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    alertController.popoverPresentationController.sourceView               = sender.titleLabel;
    alertController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;

    UIAlertAction *disconnectAction = [UIAlertAction actionWithTitle:@"Disconnect"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                                 [self.delegate settingsViewControllerShouldDisconnect:self];
                                                             }];

    UIAlertAction *cancelAction     = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:NULL];

    [alertController addAction:disconnectAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController
                       animated:YES
                     completion:NULL];
}

- (IBAction)updateServerSideReadStatusChanged:(UISwitch *)sender
{
    self.settingsManager.updateServerSideReadStatus = sender.on;
    [self.delegate settingsViewControllerDidChangeSettings:self];
}

- (IBAction)includeDaysBackChanged:(UIStepper *)sender
{
    self.settingsManager.daysBackToConsider = sender.value;
    [self updateIncludeDaysBackLabel];
    [self.delegate settingsViewControllerDidChangeSettings:self];
}

- (IBAction)includeUrgentMessagesChanged:(UISwitch *)sender
{
    self.settingsManager.includeUrgentMessages = sender.on;
    [self.delegate settingsViewControllerDidChangeSettings:self];
}

- (IBAction)includeUnreadMessagesChanged:(UISwitch *)sender
{
    self.settingsManager.includeUnreadMessages = sender.on;
   [self.delegate settingsViewControllerDidChangeSettings:self];
}


#pragma mark - UITableViewDelegate
- (void)              tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBackgroundColorsForCellAtIndexPath:indexPath];
}

// NOTE: This method is not needed for out use case as it is never called,
//       but I have included it for completeness
- (void)                tableView:(UITableView *)tableView
        didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBackgroundColorsForCellAtIndexPath:indexPath];
}

- (void)                 tableView:(UITableView *)tableView
        didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBackgroundColorsForCellAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateBackgroundColorsForCellAtIndexPath:indexPath];
}

- (void)updateBackgroundColorsForCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell           = [self.tableView cellForRowAtIndexPath:indexPath];
    BOOL             alternateState = cell.isSelected || cell.isHighlighted;
    UIColor         *alternateColor = alternateState ? [UIColor o365_primaryColor] : [UIColor o365_primaryColor];

    if (cell == self.includeSendersCell) {
        self.includeSendersCountView.backgroundColor = alternateColor;
    }
    else if (cell == self.includeConversationsCell) {
        self.includeConversationsCountView.backgroundColor = alternateColor;
    }
}


#pragma mark - SenderFilterListViewControllerDelegate
- (void)senderFilterListViewControllerDidComplete:(SenderFilterListViewController *)senderFilterListVC
{
    [self updateFilterCountLabels];
}

- (void)senderFilterListViewController:(SenderFilterListViewController *)senderFilterListVC
                    didAddSenderFilter:(SenderFilter *)senderFilter
{
    [self.settingsManager addSenderFilter:senderFilter];
    [self.delegate settingsViewControllerDidChangeSettings:self];
}

- (void)senderFilterListViewController:(SenderFilterListViewController *)senderFilterListVC
                 didRemoveSenderFilter:(SenderFilter *)senderFilter
{
    [self.settingsManager removeSenderFilter:senderFilter];
    [self.delegate settingsViewControllerDidChangeSettings:self];
}


#pragma mark - ConversationFilterListViewControllerDelegate
- (void)conversationFilterListViewControllerDidComplete:(ConversationFilterListViewController *)conversationFilterListVC
{
    [self updateFilterCountLabels];
}

- (void)conversationFilterListViewController:(ConversationFilterListViewController *)conversationFilterListVC
                 didRemoveConversationFilter:(ConversationFilter *)conversationFilter
{
    [self.settingsManager removeConversationFilter:conversationFilter];
    [self.delegate settingsViewControllerDidChangeSettings:self];
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