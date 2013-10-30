//
//  LRSettingCell.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-30.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRSettingCell.h"

@implementation LRSettingCell

+ (LRSettingCell *)createCell {
    return [[NSBundle mainBundle] loadNibNamed:@"LRSettingCell" owner:nil options:nil].lastObject;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
