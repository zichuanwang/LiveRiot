//
//  NSUserDefaults+SocialNetwork.h
//  LiveRiotSocial
//
//  Created by Gabriel Yeah on 13-11-19.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (SocialNetwork)

+ (NSString *)getFacebookUserName;
+ (void)setFacebookUserName:(NSString *)userName;

+ (NSString *)getTumblrTokenKey;
+ (NSString *)getTumblrTokenSecret;
+ (void)setTumblrTokenKey:(NSString *)key;
+ (void)setTumblrTokenSecret:(NSString *)secret;
+ (NSString *)getTumblrUserName;
+ (NSString *)getTumblrUserLink;
+ (void)setTumblrUserName:(NSString *)userName;

@end
