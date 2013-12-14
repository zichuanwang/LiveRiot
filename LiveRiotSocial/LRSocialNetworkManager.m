//
//  LRSocialNetworkManager.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-12-2.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRSocialNetworkManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "STTwitter.h"
#import "NSUserDefaults+SocialNetwork.h"
#import "TMAPIClient.h"
#import "LRFacebookProtocols.h"
#import <Social/Social.h>

static NSString *kTwitterConsumerKey =       @"Sh5JfGh1T74hpE8lh35Rhg";
static NSString *kTwitterConsumerSecret =    @"YAEI63uVUqwCw1cDlVFdocPfbBGedYAYD3odDYO8fOo";

static NSString *kTumblrConsumerKey =        @"9qs9PBtl643JGC0CBmTkQjA2fg2fupqp0WSsSwu6D8qNZMfSQd";
static NSString *kTumblrConsumerSecret =     @"U4JsgunwPqWfnXQ0oeVoV9j5QTphYR7lU8MnIVXoaPyYXXxuDw";

typedef void(^TwitterOAuthCompletionHandler)(NSError *error);

@interface LRSocialNetworkManager () <UIActionSheetDelegate>

@property (nonatomic, strong) STTwitterAPI *twitterAPI;
@property (nonatomic, copy) TwitterOAuthCompletionHandler twitterOAuthCompletionHandler;
@property (nonatomic, strong) NSArray *twitterAccounts;

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

- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:@"tumblr"].location != NSNotFound) {
        return [[TMAPIClient sharedInstance] handleOpenURL:url];
    } else if ([urlString rangeOfString:@"twitter"].location != NSNotFound) {
        return [self handleTwitterOpenURL:url];
    }else {
        // Facebook SDK * login flow *
        // Attempt to handle URLs to complete any auth (e.g., SSO) flow.
        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
            // Facebook SDK * App Linking *
            // For simplicity, this sample will ignore the link if the session is already
            // open but a more advanced app could support features like user switching.
            if (call.accessTokenData) {
                if ([FBSession activeSession].isOpen) {
                    NSLog(@"INFO: Ignoring app link because current session is open.");
                }
                else {
                    [self handleFacebookAppLink:call.accessTokenData];
                }
            }
        }];
    }
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}

// Helper method to wrap logic for handling app links.
- (void)handleFacebookAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy defaultInstance]];
    [FBSession setActiveSession:appLinkSession];
    // ... and open it from the App Link's Token.
    [appLinkSession openFromAccessTokenData:appLinkToken
                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                              // Forward any errors to the FBLoginView delegate.
                              if (error) {
                                  // [self.loginViewController loginView:nil handleError:error];
                              }
                          }];
}

- (BOOL)checkPlatformLoginStatus:(SocialNetworkType)type {
    BOOL result = NO;
    
    switch (type) {
        case SocialNetworkTypeFacebook:
            
            result = FBSession.activeSession.isOpen;
            break;
            
        case SocialNetworkTypeTwitter:
            
            result = [NSUserDefaults getTwitterSelectedAccount] || ([NSUserDefaults getTwitterTokenKey] && [NSUserDefaults getTwitterTokenSecret]);
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
            result = [NSUserDefaults getTwitterUserName];
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
    if ([NSUserDefaults getTwitterSelectedAccount]) {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted) {
                NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterType];
                self.twitterAccounts = twitterAccounts;
                for (ACAccount *account in self.twitterAccounts) {
                    if ([account.username isEqualToString:[NSUserDefaults getTwitterSelectedAccount]]) {
                        self.twitterAPI = [STTwitterAPI twitterAPIOSWithAccount:account];
                    }
                }
            }
            if (!self.twitterAPI) {
                [self closeTwitterConnection];
            }
        }];
    } else if ([NSUserDefaults getTwitterTokenKey] && [NSUserDefaults getTwitterTokenSecret]) {
        self.twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret oauthToken:[NSUserDefaults getTwitterTokenKey] oauthTokenSecret:[NSUserDefaults getTwitterTokenSecret]];
        if (!self.twitterAPI) {
            [self closeTwitterConnection];
        }
    }
}

- (void)closeTwitterConnection {
    [NSUserDefaults setTwitterSelectedAccount:nil];
    [NSUserDefaults setTwitterUserName:nil];
    [NSUserDefaults setTwitterTokenKey:nil];
    [NSUserDefaults setTwitterTokenSecret:nil];
    self.twitterAPI = nil;
    self.twitterAccounts = nil;
}

#define TWITTER_SELECT_ACCOUNT_ACTION_SHEET_TAG 1

- (void)verifyTwitterAccountCredentials {
    [self.twitterAPI verifyCredentialsWithSuccessBlock:^(NSString *username) {
        [NSUserDefaults setTwitterUserName:username];
        [NSUserDefaults setTwitterSelectedAccount:username];
        if (self.twitterOAuthCompletionHandler) {
            self.twitterOAuthCompletionHandler(nil);
            self.twitterOAuthCompletionHandler = nil;
        };
        
    } errorBlock:^(NSError *error) {
        if (self.twitterOAuthCompletionHandler) {
            self.twitterOAuthCompletionHandler(error);
            self.twitterOAuthCompletionHandler = nil;
        }
    }];
}

- (void)openTwitterConnectionUsingSystemAccountWithCallback:(void(^)(NSError *error))callback {
    if (self.twitterAccounts) {
        if (self.twitterAccounts.count > 1) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithFrame:[UIScreen mainScreen].bounds];
            actionSheet.tag = TWITTER_SELECT_ACCOUNT_ACTION_SHEET_TAG;
            actionSheet.title = @"Choose an account";
            actionSheet.delegate = self;
            for (ACAccount *account in self.twitterAccounts) {
                [actionSheet addButtonWithTitle:account.username];
            }
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = self.twitterAccounts.count;
            NSLog(@"Going to show a action sheet");
            dispatch_async(dispatch_get_main_queue(), ^{
                [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            });
        } else {
            self.twitterAPI = [STTwitterAPI twitterAPIOSWithFirstAccount];
        }
        self.twitterOAuthCompletionHandler = callback;
        [self verifyTwitterAccountCredentials];
    }
}

- (void)openTwitterConnectionUsingSafariWithCallback:(void(^)(NSError *error))callback {
    self.twitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kTwitterConsumerKey
                                                    consumerSecret:kTwitterConsumerSecret];
    
    self.twitterOAuthCompletionHandler = callback;
    
    [self.twitterAPI postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSLog(@"-- url: %@", url);
        NSLog(@"-- oauthToken: %@", oauthToken);
        [[UIApplication sharedApplication] openURL:url];
        
    } oauthCallback:@"LiveRiotSocial://twitter_access_tokens/"
                           errorBlock:^(NSError *error) {
                               NSLog(@"-- error: %@", error);
                               if (self.twitterOAuthCompletionHandler) {
                                   self.twitterOAuthCompletionHandler(error);
                                   self.twitterOAuthCompletionHandler = nil;
                               }
                           }];
}

- (void)openTwitterConnectionWithCallback:(void(^)(NSError *error))callback {
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterType];
            if (twitterAccounts && twitterAccounts.count) {
                self.twitterAccounts = twitterAccounts;
                [self openTwitterConnectionUsingSystemAccountWithCallback:callback];
            }
        }
        if (!self.twitterAccounts || !self.twitterAccounts.count){
            [self openTwitterConnectionUsingSafariWithCallback:callback];
        }
    }];
}

- (BOOL)handleTwitterOpenURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"liveriotsocial"] == NO) return NO;
    
    NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
    
    // NSString *token = d[@"oauth_token"];
    NSString *verifier = d[@"oauth_verifier"];
    
    [self.twitterAPI postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@", screenName);
        [NSUserDefaults setTwitterUserName:screenName];
        [NSUserDefaults setTwitterTokenKey:oauthToken];
        [NSUserDefaults setTwitterTokenSecret:oauthTokenSecret];
        if (self.twitterOAuthCompletionHandler) {
            self.twitterOAuthCompletionHandler(nil);
            self.twitterOAuthCompletionHandler = nil;
        }
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"-- %@", [error localizedDescription]);
        
        if (self.twitterOAuthCompletionHandler) {
            self.twitterOAuthCompletionHandler(error);
            self.twitterOAuthCompletionHandler = nil;
        }
    }];
    
    return YES;
}

- (void)postOnTwitter:(NSString *)post
           completion:(void (^)(NSError *))completion {
    [self.twitterAPI postStatusUpdate:post inReplyToStatusID:nil latitude:nil longitude:nil placeID:nil displayCoordinates:nil trimUser:nil successBlock:^(NSDictionary *status) {
        if (completion) completion(nil);
    } errorBlock:^(NSError *error) {
        if (completion) completion(error);
    }];
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
    [TMAPIClient sharedInstance].OAuthConsumerKey = kTumblrConsumerKey;
    [TMAPIClient sharedInstance].OAuthConsumerSecret = kTumblrConsumerSecret;
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == TWITTER_SELECT_ACCOUNT_ACTION_SHEET_TAG) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            self.twitterAPI = [STTwitterAPI twitterAPIOSWithAccount:self.twitterAccounts[buttonIndex]];
            [self verifyTwitterAccountCredentials];
        } else {
            if (self.twitterOAuthCompletionHandler) {
                self.twitterOAuthCompletionHandler(nil);
                self.twitterOAuthCompletionHandler = nil;
            }
        }
    }
}

@end
