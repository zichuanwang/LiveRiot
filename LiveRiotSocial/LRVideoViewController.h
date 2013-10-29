//
//  LRVideoViewController.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-3.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRVideoCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *videoPreviewImageView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;

@end

@interface LRVideoViewController : UITableViewController

@end
