//
//  DetailTableViewCell.m
//  BDVRClientDemo
//
//  Created by baidu on 16/3/15.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "DetailTableViewCell.h"

@interface DetailTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation DetailTableViewCell

- (void)setDetailTitle:(NSString *)title {
    self.detailLabel.text = title;
}

@end
