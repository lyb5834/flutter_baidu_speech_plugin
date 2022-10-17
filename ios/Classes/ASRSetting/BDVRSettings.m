//
//  BDVRSettings.m
//  BDVRClientDemo
//
//  Created by baidu on 16/3/14.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BDVRSettings.h"
#import "BDSEventManager.h"

NSString *BDVRSettings_Key = @"BDVRSettings";
NSString *kSettingsKey = @"k_settings";
static BDVRSettings *_sharedInstance = nil;

@implementation BDVRSettings

#pragma mark - Static Methods

+ (BDVRSettings *)getInstance
{
    if (_sharedInstance == nil) {
        @synchronized(self) {
            if (_sharedInstance == nil) {
                _sharedInstance = [BDVRSettings loadBDVRSettings];
            }
        }
    }
    return _sharedInstance;
}

+ (void)releaseInstance
{
    if (_sharedInstance) {
        _sharedInstance = nil;
    }
}

+ (BDVRSettings *)loadBDVRSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:BDVRSettings_Key];
    if (encodedObject == nil) {
        return [[BDVRSettings alloc] init];
    } else {
        return [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    }
}

#pragma mark - Public Methods

- (void)saveBDVRSettings
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:_sharedInstance];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:BDVRSettings_Key];
    [defaults synchronize];
}

- (void)configBDVRClient
{
    if (_sharedInstance != nil) {
        for (BDVRSettingsItem *item in _sharedInstance.settingsItemArray) {
            if (item.curItemValue != nil) {
                switch (item.groupType) {
                    case EBDGroupTypeASR: {
                        if ([item.itemKey isEqualToString:(BDS_ASR_PROPERTY_LIST)]) {
                            [[BDSEventManager createEventManagerWithName:BDS_ASR_NAME] setParameter:@[item.curItemValue]
                                                                                             forKey:item.itemKey];
                        } else {
                            [[BDSEventManager createEventManagerWithName:BDS_ASR_NAME] setParameter:item.curItemValue
                                                                                             forKey:item.itemKey];
                        }
                            break;
                    }
                        
                    case EBDGroupTypeWakeup: {
                            [[BDSEventManager createEventManagerWithName:BDS_WAKEUP_NAME] setParameter:item.curItemValue
                                                                                                forKey:item.itemKey];
                        break;
                    }
                        
                        
                    default:
                        break;
                }
            }
        }
    }
}

- (id)getCurrentValueForKey:(NSString *)key
{
    if (key.length) {
        for (BDVRSettingsItem *item in _sharedInstance.settingsItemArray) {
            if ([item.itemKey isEqualToString:key]) {
                return item.curItemValue;
            }
        }
    }
    return nil;
}

#pragma mark - Encoder & Decoder

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.settingsItemArray forKey:kSettingsKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.settingsItemArray = [decoder decodeObjectForKey:kSettingsKey];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.settingsItemArray = [[NSMutableArray alloc] initWithCapacity:1];
        [self.settingsItemArray addObject:[self createSampleRateItem]];
        [self.settingsItemArray addObject:[self createLanguageItem]];
        [self.settingsItemArray addObject:[self createToneItem]];
        [self.settingsItemArray addObject:[self createStrategyItem]];
        [self.settingsItemArray addObject:[self createEnableVADItem]];
    }
    return self;
}

#pragma mark - Common Settings

- (BDVRSettingsItem *)createSampleRateItem {
    return [[BDVRSettingsItem alloc] initWithItemTitle:@"采样率"
                                               itemKey:(NSString *)BDS_ASR_SAMPLE_RATE
                                             groupType:EBDGroupTypeASR
                                              cellType:EBDCellTypeDetail
                                          curItemValue:@(EVoiceRecognitionRecordSampleRateAuto)
                                      detailDictionary:[NSDictionary dictionaryWithObjects:@[@"自适应", @"8K", @"16K"] forKeys:@[@(0), @(1), @(2)]]];
}

- (BDVRSettingsItem *)createLanguageItem {
    return [[BDVRSettingsItem alloc] initWithItemTitle:@"识别语言"
                                               itemKey:(NSString *)BDS_ASR_LANGUAGE
                                             groupType:EBDGroupTypeASR
                                              cellType:EBDCellTypeDetail
                                          curItemValue:@(EVoiceRecognitionLanguageChinese)
                                      detailDictionary:@{@0 : @"普通话", @1 : @"粤语", @2 : @"英文", @3 : @"四川话"}];
}

- (BDVRSettingsItem *)createToneItem {
    return [[BDVRSettingsItem alloc] initWithItemTitle:@"开启提示音"
                                               itemKey:(NSString *)BDS_ASR_PLAY_TONE
                                             groupType:EBDGroupTypeASR
                                              cellType:EBDCellTypeDetail
                                          curItemValue:@(0)
                                      detailDictionary:@{@0 : @"关闭", @(EVRPlayToneAll) : @"开启"}];
}

- (BDVRSettingsItem *)createStrategyItem {
    return [[BDVRSettingsItem alloc] initWithItemTitle:@"识别策略"
                                               itemKey:(NSString *)BDS_ASR_STRATEGY
                                             groupType:EBDGroupTypeASR
                                              cellType:EBDCellTypeDetail
                                          curItemValue:@(EVR_STRATEGY_ONLINE)
                                      detailDictionary:@{@0 : @"在线识别", @4 : @"离在线并行"}];
}

- (BDVRSettingsItem *)createEnableVADItem {
    return [[BDVRSettingsItem alloc] initWithItemTitle:@"开启端点检测"
                                               itemKey:(NSString *)BDS_ASR_ENABLE_LOCAL_VAD
                                             groupType:EBDGroupTypeASR
                                              cellType:EBDCellTypeDetail
                                          curItemValue:@(YES)
                                      detailDictionary:@{@NO : @"关闭", @YES : @"开启"}];
}

@end
