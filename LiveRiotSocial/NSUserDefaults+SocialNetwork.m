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

static NSString *kTwitterTokenKey =      @"TwitterTokenKey";
static NSString *kTwitterTokenSecret =   @"TwitterTokenSecret";
static NSString *kTwitterUserName =      @"TwitterUserName";
static NSString *kTwitterSelectedAccount = @"TwitterSelectedAccount";

#define STANDARD_USER_DEFAULT [NSUserDefaults standardUserDefaults]

@implementation NSUserDefaults (SocialNetwork)

+ (NSString *)getTwitterSelectedAccount
{
    return [STANDARD_USER_DEFAULT objectForKey:kTwitterSelectedAccount];
}

+ (void)setTwitterSelectedAccount:(NSString *)accountUserName
{
    [STANDARD_USER_DEFAULT setObject:accountUserName forKey:kTwitterSelectedAccount];
    [STANDARD_USER_DEFAULT synchronize];
}

+ (NSString *)getTwitterUserName
{
    return [STANDARD_USER_DEFAULT objectForKey:kTwitterUserName];
}

+ (void)setTwitterUserName:(NSString *)userName
{
    [STANDARD_USER_DEFAULT setObject:userName forKey:kTwitterUserName];
    [STANDARD_USER_DEFAULT synchronize];
}

+ (NSString *)getTwitterTokenKey
{
    return [STANDARD_USER_DEFAULT objectForKey:kTwitterTokenKey];
}

+ (NSString *)getTwitterTokenSecret
{
    return [STANDARD_USER_DEFAULT objectForKey:kTwitterTokenSecret];
}

+ (void)setTwitterTokenKey:(NSString *)key
{
    [STANDARD_USER_DEFAULT setObject:key forKey:kTwitterTokenKey];
    [STANDARD_USER_DEFAULT synchronize];
}

+ (void)setTwitterTokenSecret:(NSString *)secret
{
    [STANDARD_USER_DEFAULT setObject:secret forKey:kTwitterTokenSecret];
    [STANDARD_USER_DEFAULT synchronize];
}

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
