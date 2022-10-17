//
//  BDVRSettings.h
//  BDVRClientDemo
//
//  Created by baidu on 16/3/14.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDVRSettingsItem.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"
#import "BDSWakeupParameters.h"
#import "BDSUploaderParameters.h"

@interface BDVRSettings : NSObject

@property (nonatomic, strong) NSMutableArray *settingsItemArray;

+ (BDVRSettings *)getInstance;
+ (void)releaseInstance;

- (void)saveBDVRSettings;
- (void)configBDVRClient;
- (id)getCurrentValueForKey:(NSString *)key;

@end
