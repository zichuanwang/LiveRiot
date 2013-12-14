//
//  LRShareViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-12-2.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRShareViewController.h"
#import "LRFacebookShareViewController.h"
#import "LRTwitterShareViewController.h"
#import "LRTumblrShareViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CRNavigationController.h"

@interface LRShareViewController ()

@property (nonatomic, copy) NSString *shareLink;
@property (nonatomic, copy) NSString *shareImageName;

@end

@implementation LRShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureNavigationBar];
    [self.textView becomeFirstResponder];
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.imageView.image = [UIImage imageNamed:self.shareImageName];
}

- (void)configureNavigationBar {
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:234 / 255. green:82 / 255. blue:81 / 255. alpha:1.];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickCancelButton:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickPostButton:)];
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

#pragma mark - Actions 

- (void)didClickCancelButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickPostButton:(UIButton *)sender {
    
}

#pragma mark - Class method

+ (void)showInViewController:(UIViewController *)viewController
                   shareLink:(NSString *)shareLink
              shareImageName:(NSString *)imageName
           socialNetworkType:(SocialNetworkType)type {
    
    BOOL signedIn = [[LRSocialNetworkManager sharedManager] checkPlatformLoginStatus:type];
    LRShareViewController *vc = nil;
    switch (type) {
        case SocialNetworkTypeFacebook:
            
            if (!signedIn) {
                // You can unquote this method to post in Facebook app
                // [LRFacebookShareViewController presentShareDialogForVideoInfo:shareLink];
                [[LRSocialNetworkManager sharedManager] openFacebookConnectionWithCallback:^(NSError *error) {
                    if (!error) {
                        [LRShareViewController showInViewController:viewController shareLink:shareLink shareImageName:imageName socialNetworkType:type];
                    }
                }];
            } else {
                vc = [[LRFacebookShareViewController alloc] init];
            }
            
            break;
            
        case SocialNetworkTypeTwitter:
            
            if (!signedIn) {
                [[LRSocialNetworkManager sharedManager] openTwitterConnectionWithCallback:^(NSError *error) {
                    [LRShareViewController showInViewController:viewController shareLink:shareLink shareImageName:imageName socialNetworkType:type];
                }];
            } else {
                vc = [[LRTwitterShareViewController alloc] init];
            }
            
            break;
            
        case SocialNetworkTypeTumblr:
            
            if (!signedIn) {
                [[LRSocialNetworkManager sharedManager] openTumblrConnectionWithCallback:^(NSError *error) {
                    [LRShareViewController showInViewController:viewController shareLink:shareLink shareImageName:imageName socialNetworkType:type];
                }];
            } else {
                vc = [[LRTumblrShareViewController alloc] init];
            }
            
            break;
            
        default:
            break;
    }
    
    if (vc) {
        vc.shareLink = shareLink;
        vc.shareImageName = imageName;
        CRNavigationController *nav = [[CRNavigationController alloc] initWithRootViewController:vc];
        [viewController presentViewController:nav animated:YES completion:nil];
    }
}

@end
