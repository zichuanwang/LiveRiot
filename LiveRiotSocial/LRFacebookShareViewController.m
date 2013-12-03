//
//  LRFacebookShareViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-11.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRFacebookShareViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LRFacebookShareViewController ()

@end

@implementation LRFacebookShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - UI

- (void)configureNavigationBar {
    [super configureNavigationBar];
    self.navigationItem.title = @"Share to Facebook";
}

#pragma mark - Action

- (void)didClickPostButton:(UIButton *)sender {
    [[LRSocialNetworkManager sharedManager] postOnFacebook:self.textView.text link:self.shareLink completion:^(NSError *error) {
        if (!error) {
            [self dismissViewControllerAnimated:YES completion:^{
                [[[UIAlertView alloc] initWithTitle:@"Succeed"
                                            message:@"Post succeeded :)"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }];
        } else {
            [self presentAlertForError:error];
        }
    }];
}

- (void)presentAlertForError:(NSError *)error {
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // When fberrorShouldNotifyUser is YES, a fberrorUserMessage can be
    // presented as a user-ready message
    if (error.fberrorShouldNotifyUser) {
        // The SDK has a message for the user, surface it.
        [[[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                    message:error.fberrorUserMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"unexpected error:%@", error);
    }
}

@end
