//
//  LRFriendCell.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-16.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRFriendCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

+ (LRFriendCell *)createCell;

@end
