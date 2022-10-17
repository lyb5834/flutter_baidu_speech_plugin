//
//  BDVRSettingsItem.h
//  BDVRClientDemo
//
//  Created by baidu on 16/3/14.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TBDSettingsGroupType
{
    EBDGroupTypeASR,
    EBDGroupTypeWakeup,
} TBDSettingsGroupType;

typedef enum TBDSettingsCellType
{
    EBDCellTypeInput,
    EBDCellTypeDetail,
    EBDCellTypeInfo,
} TBDSettingsCellType;

@interface BDVRSettingsItem : NSObject

@property (nonatomic, strong) NSString *itemKey;
@property (nonatomic, strong) NSString *itemTitle;
@property (nonatomic, strong) id curItemValue;
@property (nonatomic, assign) TBDSettingsGroupType groupType;
@property (nonatomic, assign) TBDSettingsCellType cellType;
@property (nonatomic, strong) NSDictionary *detailDictionary;

- (instancetype)initWithItemTitle:(NSString *)itemTitle
                          itemKey:(NSString *)itemKey
                        groupType:(TBDSettingsGroupType)groupType
                         cellType:(TBDSettingsCellType)cellType
                     curItemValue:(id)curItemValue
                 detailDictionary:(NSDictionary *)detailDictionary;

@end
