//
//  LRFacebookShareViewController.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-11.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRFacebookShareViewController : UIViewController {
}

+ (void)showInViewController:(UIViewController *)viewController
                   shareLink:(NSString *)shareLink
              shareImageName:(NSString *)imageName;

@end
