//
//  LRVideoDetailViewController.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-3.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRVideoDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *videoWebView;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *avatarImageName;
@property (nonatomic, copy) NSString *previewImageName;
@property (nonatomic, copy) NSString *videoLink;
@property (nonatomic, copy) NSString *timeString;

@end
