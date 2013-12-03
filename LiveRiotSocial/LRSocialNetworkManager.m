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
#import "LRFacebookProtocols.h"

static NSString *kTwitterCosumerKey =       @"Sh5JfGh1T74hpE8lh35Rhg";
static NSString *kTwitterCosumerSecret =    @"YAEI63uVUqwCw1cDlVFdocPfbBGedYAYD3odDYO8fOo";

static NSString *kTumblrCosumerKey =        @"9qs9PBtl643JGC0CBmTkQjA2fg2fupqp0WSsSwu6D8qNZMfSQd";
static NSString *kTumblrCosumerSecret =     @"U4JsgunwPqWfnXQ0oeVoV9j5QTphYR7lU8MnIVXoaPyYXXxuDw";

@interface LRSocialNetworkManager ()
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

- (void)postOnFacebook:(NSString *)post link:(NSString *)link completion:(void (^)(NSError *))completion {
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        [self requestPublishPermissionWithCompletion:^(NSError *error) {
            if (error) {
                if (completion) completion(error);
            } else {
                [self postFacebookOpenGraphAction:post link:link completion:completion];
            }
        }];
    } else {
        [self postFacebookOpenGraphAction:post link:link completion:completion];
    }
}


- (void)requestPublishPermissionWithCompletion:(void(^)(NSError *error))completion {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error && [FBSession.activeSession.permissions indexOfObject:@"publish_actions"] != NSNotFound) {
                                                // Now have the permission
                                                if (completion) completion(nil);
                                            } else if (error){
                                                // Facebook SDK * error handling *
                                                // if the operation is not user cancelled
                                                if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    NSLog(@"%@", error.localizedDescription);
                                                    if (completion) completion(error);
                                                }
                                            }
                                        }];
}

// Creates the Open Graph Action.
- (void)postFacebookOpenGraphAction:(NSString *)msg
                               link:(NSString *)link
                         completion:(void (^)(NSError *error))completion {
    
    FBRequestConnection *requestConnection = [[FBRequestConnection alloc] init];
    requestConnection.errorBehavior = FBRequestConnectionErrorBehaviorRetry | FBRequestConnectionErrorBehaviorReconnectSession;
    
    // Create an Open Graph eat action with the meal, our location, and the people we were with.
    id<LRLiveShow> video = (id<LRLiveShow>)[FBGraphObject graphObject];
    video.url = link;
    
    id<LRWatchVideoAction> action = (id<LRWatchVideoAction>)[FBGraphObject graphObject];
    action.live_show = video;
    if (msg.length > 0)
        action.message = msg;
    [(NSMutableDictionary *)action setValue:@"true" forKey:@"fb:explicitly_shared"];
    
    // Create the request and post the action to the "me/fb_sample_scrumps:eat" path.
    FBRequest *actionRequest = [FBRequest requestForPostWithGraphPath:@"me/liveriot:share"
                                                          graphObject:action];
    
    [requestConnection addRequest:actionRequest
                completionHandler:^(FBRequestConnection *connection,
                                    id result,
                                    NSError *error) {
                    if (completion) completion(error);
                }];
    [requestConnection start];
}

// Jump to Facebook app or Safari to post
+ (void)presentFacebookShareDialogWithLink:(NSString *)shareLink {
    id liveShow = [FBGraphObject openGraphObjectForPostWithType:@"liveriot:live_show"
                                                          title:@"Amazing live music"
                                                          image:nil
                                                            url:shareLink
                                                    description:[@"Description " stringByAppendingString:@"test."]];
    
    id<LRWatchVideoAction> action = (id<LRWatchVideoAction>)[FBGraphObject graphObject];
    action.live_show = liveShow;
    
    
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:@"liveriot:share"
                                 previewPropertyName:@"live_show"
                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                 if (!error) {
                                                     NSLog(@"Results: %@", results);
                                                 } else {
                                                     NSLog(@"%@", error);
                                                     [[[UIAlertView alloc] initWithTitle:@"Failure"
                                                                                 message:[NSString stringWithFormat:@"%@", error]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"I See"
                                                                       otherButtonTitles:nil] show];
                                                 }
                                             }];
    
}

#pragma mark - Twitter

- (void)setupTwitter {
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:kTwitterCosumerKey
                                                     andSecret:kTwitterCosumerSecret];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
}

- (void)closeTwitterConnection {
    [[FHSTwitterEngine sharedEngine] clearAccessToken];
}

- (void)openTwitterConnectionWithController:(UIViewController *)sender
                                   callback:(void(^)(BOOL success))callback {
    [[FHSTwitterEngine sharedEngine] showOAuthLoginControllerFromViewController:sender withCompletion:^(BOOL success) {
        NSString* userName = [[FHSTwitterEngine sharedEngine] loggedInUsername];
        NSLog(success ? @"Twitter OAuth Login success with UserName %@" : @"Twitter OAuth Loggin Failed %@", userName);
        if (callback) callback(success);
    }];
}

- (void)postOnTwitter:(NSString *)post completion:(void (^)(NSError *))completion {
    dispatch_async(GCDBackgroundThread, ^{
        // append the twitter photo card link to the tweet
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSError *error = [[FHSTwitterEngine sharedEngine] postTweet:post];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error.code == 204) {
            error = [NSError errorWithDomain:@"" code:204 userInfo:@{NSLocalizedDescriptionKey : @"Whoops!You already tweeted that..."}];
        }
        
        dispatch_sync(GCDMainThread, ^{
            if (completion) completion(error);
            NSLog(@"%d, %@", error.code, error.localizedDescription);
        });
    });
}

#pragma mark - Tumblr

- (void)postOnTumblr:(NSString *)post
                link:(NSString *)link
          completion:(void (^)(NSError *))completion {
    [[TMAPIClient sharedInstance] link:[NSUserDefaults getTumblrUserLink]
                            parameters:@{@"url": link,
                                         @"title" : @"Video from LiveRiot",
                                         @"description" : post}
                              callback:^(id a, NSError *error) {
                                  if (completion) completion(error);
                              }];
}

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
