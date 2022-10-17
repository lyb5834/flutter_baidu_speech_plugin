//
//  BDVRSettingsItem.m
//  BDVRClientDemo
//
//  Created by baidu on 16/3/14.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BDVRSettingsItem.h"

NSString *kKeyKey = @"setting_item_key";
NSString *kTitleKey = @"setting_item_title";
NSString *kGroupTypeKey = @"setting_item_group_type";
NSString *kCellTypeKey = @"setting_item_cell_type";
NSString *kCurItemValueKey = @"setting_cur_item_value";
NSString *kDetailDicKey = @"setting_detail_dic_key";

@implementation BDVRSettingsItem

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.itemKey forKey:kKeyKey];
    [encoder encodeObject:self.itemTitle forKey:kTitleKey];
    [encoder encodeObject:@(self.groupType) forKey:kGroupTypeKey];
    [encoder encodeObject:@(self.cellType) forKey:kCellTypeKey];
    [encoder encodeObject:self.curItemValue forKey:kCurItemValueKey];
    [encoder encodeObject:self.detailDictionary forKey:kDetailDicKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.itemKey = [decoder decodeObjectForKey:kKeyKey];
        self.itemTitle = [decoder decodeObjectForKey:kTitleKey];
        self.groupType = [[decoder decodeObjectForKey:kGroupTypeKey] intValue];
        self.cellType = [[decoder decodeObjectForKey:kCellTypeKey] intValue];
        self.curItemValue = [decoder decodeObjectForKey:kCurItemValueKey];
        self.detailDictionary = [decoder decodeObjectForKey:kDetailDicKey];
    }
    return self;
}

- (instancetype)initWithItemTitle:(NSString *)itemTitle
                          itemKey:(NSString *)itemKey
                        groupType:(TBDSettingsGroupType)groupType
                         cellType:(TBDSettingsCellType)cellType
                     curItemValue:(id)curItemValue
                 detailDictionary:(NSDictionary *)detailDictionary {
    if (self = [super init]) {
        self.itemTitle = itemTitle;
        self.itemKey = itemKey;
        self.groupType = groupType;
        self.cellType = cellType;
        self.curItemValue = curItemValue;
        self.detailDictionary = detailDictionary;
    }
    return self;
}

@end
