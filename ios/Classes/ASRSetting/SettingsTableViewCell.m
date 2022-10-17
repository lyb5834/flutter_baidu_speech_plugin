//
//  SettingsTableViewCell.m
//  BDVRClientDemo
//
//  Created by baidu on 16/3/14.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "SettingsTableViewCell.h"
#import "DetailTableViewController.h"

@interface SettingsTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation SettingsTableViewCell

- (void)setSettingsItem:(BDVRSettingsItem *)settingsItem {
    _settingsItem = settingsItem;
    switch (_settingsItem.cellType) {
        case EBDCellTypeInfo: {
            self.titleLabel.text = [NSString stringWithFormat:@"%@: %@", _settingsItem.itemTitle, _settingsItem.curItemValue];
            self.accessoryType = UITableViewCellAccessoryNone;
            self.userInteractionEnabled = NO;
            break;
        }
            
        default: {
            self.titleLabel.text = _settingsItem.itemTitle;
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.userInteractionEnabled = YES;
            break;
        }
    }
    
}

@end
