//
//  LRTwitterShareViewController.m
//  LiveRiotSocial
//
//  Created by Haoyu Huang on 10/28/13.
//  Copyright (c) 2013 LiveRiot. All rights reserved.
//

#import "LRTwitterShareViewController.h"
#import "CRNavigationController.h"
#import "FHSTwitterEngine.h"
#import "Social/SLComposeViewController.h"
#import "Social/SLServiceTypes.h"


@interface LRTwitterShareViewController () <UIAlertViewDelegate>

@end

@implementation LRTwitterShareViewController

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
    
    if ([[FHSTwitterEngine sharedEngine] isAuthorized] == YES) {
        // the access token is authorzied
        [self postTweets];
    } else {
        // the access token is not existed or invalid, authenticate user with OAuth
        [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
            NSLog(success ? @"Twitter OAuth Login success" : @"Twitter OAuth Loggin Failed");
            if (success) {
                [self postTweets];
                
            }
        }];
    }
}

#pragma mark - Twitter

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

// Post tweets to Twitter after OAuth success
- (void)postTweets {
    [self.textView resignFirstResponder];
    
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            NSString* tweet = self.textView.text;
            // append the twitter photo card link to the tweet
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            NSError *returnCode = [[FHSTwitterEngine sharedEngine]postTweet:tweet];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSString *title = nil;
            NSString *message = nil;
            
            if (returnCode) {
                switch (returnCode.code) {
                    case 204:
                        message = @"Whoops!You already tweeted that...";
                        break;
                    default:
                        message = returnCode.description;
                        break;
                }
                title = [NSString stringWithFormat:@"Error %ld",(long)returnCode.code];
            } else {
                title = @"Tweet Posted";
                message = self.textView.text;
            }
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }
    });
}


@end
