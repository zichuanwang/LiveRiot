//
//  NSUserDefaults+Addition.h
//  LiveRiotSocial
//
//  Created by Gabriel Yeah on 13-11-19.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Addition)

+ (NSString *)getTMToken;
+ (NSString *)getTMSecret;
+ (BOOL)isTMLoggedIn;

+ (void)setTMToken:(NSString *)token;
+ (void)setTMSecret:(NSString *)secret;
+ (void)setTMLoggedIn:(BOOL)loggedIn;

+ (void)loginTMWithToken:(NSString *)token secret:(NSString *)secret;
+ (void)logoutTM;

+ (NSString *)getTMUserName;
+ (NSString *)getTMLink;
+ (void)setTMUserName:(NSString *)userName;

@end
