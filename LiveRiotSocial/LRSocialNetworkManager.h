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

- (BOOL)checkPlatformLoginStatus:(SocialNetworkType)type;

- (void)openFacebookConnectionWithCallback:(void(^)(NSError *))callback;

- (void)closeFacebookConnection;

- (void)openTwitterConnectionWithController:(UIViewController *)sender
                                   callback:(void(^)(BOOL success))callback;

- (void)closeTwitterConnection;

- (void)openTumblrConnectionWithCallback:(void(^)(NSError *))callback;

- (void)closeTumblrConnection;

- (NSString *)userNameForPlatform:(SocialNetworkType)type;

- (void)setup;

- (void)postOnTwitter:(NSString *)post completion:(void (^)(NSError *))completion;

- (void)postOnTumblr:(NSString *)post
                link:(NSString *)link
          completion:(void (^)(NSError *))completion;

+ (void)presentFacebookShareDialogWithLink:(NSString *)shareLink;

- (void)postOnFacebook:(NSString *)post
                  link:(NSString *)link
            completion:(void (^)(NSError *))completion;

@end
