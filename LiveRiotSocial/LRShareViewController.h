//
//  LRShareViewController.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-12-2.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LRSocialNetworkManager.h"

@interface LRShareViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, copy, readonly) NSString *shareLink;
@property (nonatomic, copy, readonly) NSString *shareImageName;

- (void)configureNavigationBar;

+ (void)showInViewController:(UIViewController *)viewController
                   shareLink:(NSString *)shareLink
              shareImageName:(NSString *)imageName
           socialNetworkType:(SocialNetworkType)type;

@end
