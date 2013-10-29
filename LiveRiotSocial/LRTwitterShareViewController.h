//
//  LRTwitterShareViewController.h
//  LiveRiotSocial
//
//  Created by Haoyu Huang on 10/28/13.
//  Copyright (c) 2013 LiveRiot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LRTwitterShareViewController : UIViewController {
    CGRect _oldRect;
    NSTimer *_caretVisibilityTimer;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;

+ (void) showInViewController:(UIViewController *) viewController;

@end
