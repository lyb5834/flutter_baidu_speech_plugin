//
//  SettingsTableViewCell.h
//  BDVRClientDemo
//
//  Created by baidu on 16/3/14.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDVRSettingsItem.h"

@interface SettingsTableViewCell : UITableViewCell

@property (strong, nonatomic) BDVRSettingsItem *settingsItem;

@end
