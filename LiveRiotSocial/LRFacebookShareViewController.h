//
//  LRFacebookShareViewController.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-11.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRFacebookShareViewController : UIViewController {
    CGRect _oldRect;
    NSTimer *_caretVisibilityTimer;
}

+ (void)showInViewController:(UIViewController *)viewController;

@end
