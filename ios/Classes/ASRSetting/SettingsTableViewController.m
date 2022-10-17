//
//  SettingsTableViewController.m
//  BDVRClientDemo
//
//  Created by baidu on 16/3/14.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "BDVRSettings.h"
#import "SettingsTableViewCell.h"
#import "SettingsTableViewController.h"
#import "DetailTableViewController.h"

NSString *settingsIdentifier = @"settingsCell";

@interface SettingsTableViewController ()

@property (nonatomic, strong) NSMutableArray *asrSettings;
@property (nonatomic, strong) NSMutableArray *wakeupSettings;
@property (nonatomic, strong) BDVRSettings *settings;
@property (nonatomic, strong) BDVRSettingsItem *selectedItem;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.asrSettings = [[NSMutableArray alloc] initWithCapacity:1];
    self.wakeupSettings = [[NSMutableArray alloc] initWithCapacity:1];

    self.settings = [BDVRSettings getInstance];
    for (BDVRSettingsItem *item in self.settings.settingsItemArray) {
        switch (item.groupType) {
            case EBDGroupTypeASR:
                [self.asrSettings addObject:item];
                break;
            case EBDGroupTypeWakeup:
                [self.wakeupSettings addObject:item];
                break;
            default:
                break;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[BDVRSettings getInstance] saveBDVRSettings];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.asrSettings.count;
        case 1:
            return self.wakeupSettings.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    BDVRSettingsItem *item;
    
    if (indexPath.section == 0) {
        item = [self.asrSettings objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        item = [self.wakeupSettings objectAtIndex:indexPath.row];
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:settingsIdentifier forIndexPath:indexPath];
    [(SettingsTableViewCell *)cell setSettingsItem:item];
    
    return cell;
}

#pragma mark - Table view delegate

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.selectedItem = ((SettingsTableViewCell *)cell).settingsItem;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailTableViewController *dest = [segue destinationViewController];
    dest.settingsItem = self.selectedItem;
}

@end
