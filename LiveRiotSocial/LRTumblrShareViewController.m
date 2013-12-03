//
//  LRTumblrShareViewController.m
//  LiveRiotSocial
//
//  Created by Gabriel Yeah on 13-10-30.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRTumblrShareViewController.h"
#import "LRSocialNetworkManager.h"

@interface LRTumblrShareViewController ()

@end

@implementation LRTumblrShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textView setText:[NSString stringWithFormat:@"#LiveRiotMusic %@", self.shareLink]];
}

- (void)configureNavigationBar {
    [super configureNavigationBar];
    self.navigationItem.title = @"Share to Tumblr";
}

#pragma mark - Actions

- (void)didClickPostButton:(UIButton *)sender {
    NSString *content = self.textView.text;
    if (!content || [content isEqualToString:@""]) {
        content = @"Check it out!";
    }
    
    [[LRSocialNetworkManager sharedManager] postOnTumblr:content link:self.shareLink completion:^(NSError *error) {
        [self dismiss:error];
    }];
}

- (void)dismiss:(NSError *)error {
    if (!error) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[[UIAlertView alloc] initWithTitle:@"Success"
                                        message:[NSString stringWithFormat:@"Post succeeded :)"]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failed"
                                    message:error.localizedDescription
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
