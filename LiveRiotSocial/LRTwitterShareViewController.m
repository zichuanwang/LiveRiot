//
//  LRTwitterShareViewController.m
//  LiveRiotSocial
//
//  Created by Haoyu Huang on 10/28/13.
//  Copyright (c) 2013 LiveRiot. All rights reserved.
//

#import "LRTwitterShareViewController.h"

@interface LRTwitterShareViewController () <UIAlertViewDelegate>

@end

@implementation LRTwitterShareViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.textView setText:[NSString stringWithFormat:@"#LiveRiotMusic %@", self.shareLink]];
}

#pragma mark - UI

- (void)configureNavigationBar {
    [super configureNavigationBar];
    self.navigationItem.title = @"Share to Twitter";
}

#pragma mark - Action

- (void)didClickPostButton:(UIButton *)sender {
    [self postTweets];
}

#pragma mark - Twitter

// Post tweets to Twitter after OAuth success
- (void)postTweets {
    [self.textView resignFirstResponder];
    [[LRSocialNetworkManager sharedManager] postOnTwitter:self.textView.text completion:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Failure" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Post succeeded :)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}


@end
