//
//  NSUserDefaults+SocialNetwork.m
//  LiveRiotSocial
//
//  Created by Gabriel Yeah on 13-11-19.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "NSUserDefaults+SocialNetwork.h"

static NSString *kTumblrTokenKey =      @"TumblrTokenKey";
static NSString *kTumblrTokenSecret =   @"TumblrTokenSecret";
static NSString *kTumblrUserName =      @"TumblrUserName";
static NSString *kTumblrUserLink =      @"TumblrUserLink";

static NSString *kFacebookUserName =    @"FacebookUserName";

#define STANDARD_USER_DEFAULT [NSUserDefaults standardUserDefaults]

@implementation NSUserDefaults (SocialNetwork)

+ (NSString *)getFacebookUserName
{
    return [STANDARD_USER_DEFAULT objectForKey:kFacebookUserName];
}

+ (void)setFacebookUserName:(NSString *)userName
{
    [STANDARD_USER_DEFAULT setObject:userName forKey:kFacebookUserName];
    [STANDARD_USER_DEFAULT synchronize];
}

+ (NSString *)getTumblrTokenKey
{
    return [STANDARD_USER_DEFAULT objectForKey:kTumblrTokenKey];
}

+ (NSString *)getTumblrTokenSecret
{
    return [STANDARD_USER_DEFAULT objectForKey:kTumblrTokenSecret];
}

+ (void)setTumblrTokenKey:(NSString *)key
{
    [STANDARD_USER_DEFAULT setObject:key forKey:kTumblrTokenKey];
    [STANDARD_USER_DEFAULT synchronize];
}

+ (void)setTumblrTokenSecret:(NSString *)secret
{
    [STANDARD_USER_DEFAULT setObject:secret forKey:kTumblrTokenSecret];
    [STANDARD_USER_DEFAULT synchronize];
}

+ (NSString *)getTumblrUserName
{
    return [STANDARD_USER_DEFAULT objectForKey:kTumblrUserName];
}

+ (NSString *)getTumblrUserLink
{
    return [STANDARD_USER_DEFAULT objectForKey:kTumblrUserLink];
}

+ (void)setTumblrUserName:(NSString *)userName
{
    NSString *link = [NSString stringWithFormat:@"%@.tumblr.com", userName];
    [STANDARD_USER_DEFAULT setObject:userName forKey:kTumblrUserName];
    [STANDARD_USER_DEFAULT setObject:link forKey:kTumblrUserLink];
    [STANDARD_USER_DEFAULT synchronize];
}

@end
