//
//  LRSettingCell.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-30.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRSettingCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *platformLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UIImageView *separatorImageView;

+ (LRSettingCell *)createCell;

@end
