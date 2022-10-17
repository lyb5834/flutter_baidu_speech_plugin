//
//  DetailTableViewController.m
//  BDVRClientDemo
//
//  Created by baidu on 16/3/15.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "DetailTableViewController.h"
#import "DetailInputTableViewCell.h"
#import "DetailTableViewCell.h"
#import "BDSEventManager.h"
#import "BDSASRParameters.h"
#import "BDSWakeupParameters.h"

NSString *detailCellIdentifier = @"detailCell";
NSString *detailInputCellIdentifier = @"detailInputCell";

@interface DetailTableViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSArray *sortedKeyArray;

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled = YES;
}

- (void)setSettingsItem:(BDVRSettingsItem *)settingsItem {
    _settingsItem = settingsItem;
    self.title = _settingsItem.itemTitle;
    switch (_settingsItem.cellType) {
        case EBDCellTypeDetail: {
            self.sortedKeyArray = [_settingsItem.detailDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 intValue] > [obj2 intValue];
            }];
            break;
        }
        case EBDCellTypeInput: {
            self.tableView.scrollEnabled = NO;
            break;
        }
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.settingsItem.cellType) {
        case EBDCellTypeDetail:
            return self.settingsItem.detailDictionary.count;
        case EBDCellTypeInput:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (self.settingsItem.cellType) {
        case EBDCellTypeDetail: {
            cell = [tableView dequeueReusableCellWithIdentifier:detailCellIdentifier forIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSNumber *curSelectedKey = _settingsItem.curItemValue;
            NSNumber *curKey = [self.sortedKeyArray objectAtIndex:indexPath.row];
            if (curKey == curSelectedKey) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            [(DetailTableViewCell *)cell setDetailTitle:[self.settingsItem.detailDictionary objectForKey:curKey]];
            break;
        }
        case EBDCellTypeInput: {
            cell = [tableView dequeueReusableCellWithIdentifier:detailInputCellIdentifier forIndexPath:indexPath];
            [[(DetailInputTableViewCell *)cell inputTextField] setDelegate:self];
            [[(DetailInputTableViewCell *)cell inputTextField] setReturnKeyType:UIReturnKeyDone];
            [[(DetailInputTableViewCell *)cell inputTextField] setPlaceholder:_settingsItem.itemTitle];
            [[(DetailInputTableViewCell *)cell inputTextField] setText:_settingsItem.curItemValue];
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.settingsItem.cellType == EBDCellTypeDetail) {
        if (self.settingsItem.curItemValue != [_sortedKeyArray objectAtIndex:indexPath.row]) {
            self.settingsItem.curItemValue = [_sortedKeyArray objectAtIndex:indexPath.row];
            if ([_settingsItem.itemKey isEqualToString:((NSString *)BDS_ASR_PROPERTY_LIST)]) {
                [[BDSEventManager createEventManagerWithName:BDS_ASR_NAME] setParameter:@[_settingsItem.curItemValue]
                                                                                 forKey:_settingsItem.itemKey];
            } else {
                [[BDSEventManager createEventManagerWithName:BDS_ASR_NAME] setParameter:_settingsItem.curItemValue
                                                                                 forKey:_settingsItem.itemKey];
            }
        }
        [tableView reloadData];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.text != nil && ![textField.text isEqualToString:_settingsItem.curItemValue]) {
        _settingsItem.curItemValue = textField.text;
        [[BDSEventManager createEventManagerWithName:BDS_WAKEUP_NAME] setParameter:_settingsItem.curItemValue
                                                                            forKey:_settingsItem.itemKey];
    }
    
    return YES;
}

@end
