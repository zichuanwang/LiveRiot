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

static NSString *kTwitterCosumerKey =       @"Sh5JfGh1T74hpE8lh35Rhg";
static NSString *kTwitterCosumerSecret =    @"YAEI63uVUqwCw1cDlVFdocPfbBGedYAYD3odDYO8fOo";

static NSString *kTumblrCosumerKey =        @"9qs9PBtl643JGC0CBmTkQjA2fg2fupqp0WSsSwu6D8qNZMfSQd";
static NSString *kTumblrCosumerSecret =     @"U4JsgunwPqWfnXQ0oeVoV9j5QTphYR7lU8MnIVXoaPyYXXxuDw";

@interface LRSocialNetworkManager () <FHSTwitterEngineAccessTokenDelegate>
@end

@implementation LRSocialNetworkManager

static dispatch_once_t LRSocialNetworkManagerPredicate;
static LRSocialNetworkManager *sharedManager = nil;

+ (LRSocialNetworkManager *)sharedManager {
    dispatch_once(&LRSocialNetworkManagerPredicate, ^{
        sharedManager = [[LRSocialNetworkManager alloc] init];
    });
    
    return sharedManager;
}

- (void)setup {
    [self setupFacebook];
    [self setupTwitter];
    [self setupTumblr];
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
            
            result = [NSUserDefaults getTumblrTokenKey] && [NSUserDefaults getTumblrTokenSecret];
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
            result = [NSUserDefaults getFacebookUserName];
            break;
            
        case SocialNetworkTypeTwitter:
            result = [[FHSTwitterEngine sharedEngine] loggedInUsername];
            break;
            
        case SocialNetworkTypeTumblr:
            result = [NSUserDefaults getTumblrUserName];
            break;
            
        default:
            break;
    }
    
    return result;
}

#pragma mark - Facebook



- (void)setupFacebook {
    if (!FBSession.activeSession.isOpen) {
        // create a fresh session object
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                                                 FBSessionState status,
                                                                 NSError *error) {
                // we recurse here, in order to update buttons and labels
                NSLog(@"Facebook session status %d", status);
            }];
        }
    }
}

- (void)populateFacebookUserDetailsWithCallback:(void(^)(NSError *))callback {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 [NSUserDefaults setFacebookUserName:user.name];
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

- (void)setupTwitter {
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:kTwitterCosumerKey
                                                     andSecret:kTwitterCosumerSecret];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
}

- (void)closeTwitterConnection {
    [[FHSTwitterEngine sharedEngine] clearAccessToken];
}

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
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

- (void)setupTumblr {
    [TMAPIClient sharedInstance].OAuthConsumerKey = kTumblrCosumerKey;
    [TMAPIClient sharedInstance].OAuthConsumerSecret = kTumblrCosumerSecret;
    if ([self checkPlatformLoginStatus:SocialNetworkTypeTumblr]) {
        [TMAPIClient sharedInstance].OAuthToken = [NSUserDefaults getTumblrTokenKey];
        [TMAPIClient sharedInstance].OAuthTokenSecret = [NSUserDefaults getTumblrTokenSecret];
    }
}

- (void)closeTumblrConnection {
    [NSUserDefaults setTumblrTokenKey:nil];
    [NSUserDefaults setTumblrTokenSecret:nil];
    
    NSHTTPCookieStorage *cookieStorage =  [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie  *cookie in [cookieStorage cookies]) {
        NSLog(@"%@, %@", cookie.name, cookie.domain);
        if ([cookie.domain rangeOfString:@"tumblr"].location != NSNotFound) {
            NSLog(@"%@", cookie.name);
            [cookieStorage deleteCookie:cookie];
        }
    }
}

- (void)populateTumblrUserDetailsWithCallback:(void(^)(NSError *))callback {
    [[TMAPIClient sharedInstance] userInfo:^(id dict, NSError *error) {
        if (!error) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                NSDictionary *userInfoDict = dict[@"user"];
                NSString *userName = userInfoDict[@"name"];
                [NSUserDefaults setTumblrUserName:userName];
            }
        }
        if (callback) callback(error);
    }];
}

- (void)openTumblrConnectionWithCallback:(void(^)(NSError *))callback {
    [[TMAPIClient sharedInstance] authenticate:@"LiveRiotSocial" callback:^(NSError *error) {
        if (!error) {
            [NSUserDefaults setTumblrTokenKey:[TMAPIClient sharedInstance].OAuthToken];
            [NSUserDefaults setTumblrTokenSecret:[TMAPIClient sharedInstance].OAuthTokenSecret];
            
            [self populateTumblrUserDetailsWithCallback:callback];
        } else {
            NSLog(@"%@", error.localizedDescription);
            if (callback) callback(error);
        }
    }];
}

@end
