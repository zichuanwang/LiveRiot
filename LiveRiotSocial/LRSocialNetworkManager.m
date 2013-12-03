//
//  LRSocialNetworkManager.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-12-2.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRSocialNetworkManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FHSTwitterEngine.h"
#import "NSUserDefaults+SocialNetwork.h"

#import "TMAPIClient.h"

@interface LRSocialNetworkManager () <FHSTwitterEngineAccessTokenDelegate>
@end

@implementation LRSocialNetworkManager

static dispatch_once_t LRSocialNetworkManagerPredicate;
static LRSocialNetworkManager *sharedManager = nil;

+ (LRSocialNetworkManager *)sharedManager {
    dispatch_once(&LRSocialNetworkManagerPredicate, ^{
        sharedManager = [[LRSocialNetworkManager alloc] init];
        [sharedManager setupTwitterEngine];
    });
    
    return sharedManager;
}

- (BOOL)checkPlatformLoginStatus:(SocialNetworkType)type {
    BOOL result = NO;
    
    switch (type) {
        case SocialNetworkTypeFacebook:
            
            result = FBSession.activeSession.isOpen;
            break;
            
        case SocialNetworkTypeTwitter:
            
            result = [[FHSTwitterEngine sharedEngine] isAuthorized];
            break;
            
        case SocialNetworkTypeTumblr:
            
            result = [NSUserDefaults isTMLoggedIn];
            break;
            
        default:
            break;
    }
    
    return result;
}

- (NSString *)userNameForPlatform:(SocialNetworkType)type {
    NSString *result = nil;
    switch (type) {
        case SocialNetworkTypeFacebook:
            
            result = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentFacebookUserName];
            break;
            
        case SocialNetworkTypeTwitter:
            
            result = [[FHSTwitterEngine sharedEngine] loggedInUsername];
            break;
            
        case SocialNetworkTypeTumblr:
            
            result = [NSUserDefaults getTMUserName];
            break;
            
        default:
            break;
    }
    
    return result;
}

#pragma mark - Facebook

static NSString *kCurrentFacebookUserName = @"kCurrentFacebookUserName";

- (void)populateFacebookUserDetailsWithCallback:(void(^)(NSError *))callback {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 [[NSUserDefaults standardUserDefaults] setObject:user.name forKey:kCurrentFacebookUserName];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 // self.userProfileImage.profileID = [user objectForKey:@"id"];
             }
             if (callback) callback(error);
         }];
    }
}

- (void)openFacebookConnectionWithCallback:(void(^)(NSError *))callback {
    // if the session isn't open, let's open it now and present the login UX to the user
    [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
        // and here we make sure to update our UX according to the new session state
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Failure" message:error.localizedDescription delegate:nil cancelButtonTitle:@"I see" otherButtonTitles:nil] show];
        }
        [self populateFacebookUserDetailsWithCallback:callback];
    }];
}

- (void)closeFacebookConnection {
    [FBSession.activeSession closeAndClearTokenInformation];
    [FBSession setActiveSession:nil];
}

#pragma mark - Twitter

- (void)closeTwitterConnection {
    [[FHSTwitterEngine sharedEngine] clearAccessToken];
}

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
}

- (void)setupTwitterEngine {
    // twitter engine set up...
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:@"Sh5JfGh1T74hpE8lh35Rhg" andSecret:@"YAEI63uVUqwCw1cDlVFdocPfbBGedYAYD3odDYO8fOo"];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
}

- (void)openTwitterConnectionWithController:(UIViewController *)sender
                                   callback:(void(^)(NSError *))callback {
    [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:sender withCompletion:^(BOOL success) {
        NSString* userName = [[FHSTwitterEngine sharedEngine] loggedInUsername];
        NSLog(success ? @"Twitter OAuth Login success with UserName %@" : @"Twitter OAuth Loggin Failed %@", userName);
        if (callback) callback(nil);
    }];
}

#pragma mark - Tumblr

- (void)closeTumblrConnection {
    [NSUserDefaults logoutTM];
}

- (void)populateTumblrUserDetailsWithCallback:(void(^)(NSError *))callback {
    [[TMAPIClient sharedInstance] userInfo:^(id dict, NSError *error) {
        if (!error) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                NSDictionary *userInfoDict = dict[@"user"];
                NSString *userName = userInfoDict[@"name"];
                [NSUserDefaults setTMUserName:userName];
            }
        }
        if (callback) callback(error);
    }];
}

- (void)openTumblrConnectionWithCallback:(void(^)(NSError *))callback {
    [[TMAPIClient sharedInstance] authenticate:@"LiveRiotSocial" callback:^(NSError *error) {
        if (!error) {
            [NSUserDefaults loginTMWithToken:[TMAPIClient sharedInstance].OAuthToken
                                      secret:[TMAPIClient sharedInstance].OAuthTokenSecret];
            
            [self populateFacebookUserDetailsWithCallback:callback];
        } else {
            if (callback) callback(error);
        }
    }];
}

@end
