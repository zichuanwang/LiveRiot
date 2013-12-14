//
//  LRSocialNetworkManager.h
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-12-2.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum SocialNetworkType : NSUInteger {
    SocialNetworkTypeFacebook,
    SocialNetworkTypeTwitter,
    SocialNetworkTypeTumblr,
} SocialNetworkType;


@interface LRSocialNetworkManager : NSObject

+ (LRSocialNetworkManager *)sharedManager;

// Call this method in AppDelegate |- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions|
- (void)setup;

// Call this method in AppDelgate |- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation|
- (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

// Return Yes for login accounts, return No for signed out accounts
- (BOOL)checkPlatformLoginStatus:(SocialNetworkType)type;

- (NSString *)userNameForPlatform:(SocialNetworkType)type;

- (void)openFacebookConnectionWithCallback:(void(^)(NSError *))callback;

- (void)closeFacebookConnection;

- (void)openTwitterConnectionWithCallback:(void(^)(NSError *error))callback;

- (void)closeTwitterConnection;

- (void)openTumblrConnectionWithCallback:(void(^)(NSError *))callback;

- (void)closeTumblrConnection;

- (void)postOnTwitter:(NSString *)post
           completion:(void (^)(NSError *))completion;

- (void)postOnTumblr:(NSString *)post
                link:(NSString *)link
          completion:(void (^)(NSError *))completion;

+ (void)presentFacebookShareDialogWithLink:(NSString *)shareLink;

- (void)postOnFacebook:(NSString *)post
                  link:(NSString *)link
            completion:(void (^)(NSError *))completion;

@end
