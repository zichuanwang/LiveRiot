//
//  NSUserDefaults+Addition.m
//  LiveRiotSocial
//
//  Created by Gabriel Yeah on 13-11-19.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "NSUserDefaults+Addition.h"

#define kTMTokenKey       @"kTMTokenKey"
#define kTMTokenSecret    @"kTMTokenSecret"
#define kTMTokenLoggedIn  @"kTMTkTMTokenLoggedInokenKey"
#define kTMUserName       @"kTMUserName"
#define kTMUserLink       @"kTMUserLink"

@implementation NSUserDefaults (Addition)

+ (NSString *)getTMToken
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:kTMTokenKey];
}

+ (NSString *)getTMSecret
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:kTMTokenSecret];
}

+ (BOOL)isTMLoggedIn
{
  return [[[NSUserDefaults standardUserDefaults] objectForKey:kTMTokenLoggedIn] boolValue];
}

+ (void)setTMToken:(NSString *)token
{
  [[NSUserDefaults standardUserDefaults] setObject:token forKey:kTMTokenKey];
}

+ (void)setTMSecret:(NSString *)secret
{
  [[NSUserDefaults standardUserDefaults] setObject:secret forKey:kTMTokenSecret];
}

+ (void)setTMLoggedIn:(BOOL)loggedIn
{
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:loggedIn] forKey:kTMTokenLoggedIn];
}

+ (void)loginTMWithToken:(NSString *)token secret:(NSString *)secret
{
  [NSUserDefaults setTMToken:token];
  [NSUserDefaults setTMSecret:secret];
  [NSUserDefaults setTMLoggedIn:YES];
}

+ (void)logoutTM
{
  [NSUserDefaults setTMToken:@""];
  [NSUserDefaults setTMSecret:@""];
  [NSUserDefaults setTMLoggedIn:NO];
  [NSUserDefaults setTMUserName:@""];
}

+ (NSString *)getTMUserName
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:kTMUserName];
}

+ (NSString *)getTMLink
{
  return [[NSUserDefaults standardUserDefaults] objectForKey:kTMUserLink];
}


+ (void)setTMUserName:(NSString *)userName
{
  NSString *link = [NSString stringWithFormat:@"%@.tumblr.com", userName];
  [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kTMUserName];
  [[NSUserDefaults standardUserDefaults] setObject:link forKey:kTMUserLink];
}

@end
