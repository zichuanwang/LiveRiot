//
//  LRTwitterOS.h
//  LiveRiotSocial
//
//  Created by Haoyu Huang on 12/06/13.
//  Copyright (c) 2013 LiveRiot. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSUInteger, STTwitterOSErrorCode) {
    STTwitterOSSystemCannotAccessTwitter,
    STTwitterOSCannotFindTwitterAccount,
    STTwitterOSUserDeniedAccessToTheirAccounts,
    STTwitterOSNoTwitterAccountIsAvailable
};

@class ACAccount;

@interface LRTwitterOS : NSObject

+ (LRTwitterOS *)twitterIOSEngine;

- (NSArray *)twitterIOSAccountswithCallback:(void(^)(NSError *error))errorBlock;

- (int)twitterIOSAccountSize;

- (BOOL)isLoggedIn;

- (NSString *)loggedInUserName;

- (void)loadTwitterAccount;

- (void)openTwitterIOSConnectionWithName:(NSString *)twitterAccount;

- (void)showTweetSheetWithController:(UIViewController *)controller initText:(NSString *)initText completion:(void (^)(NSError *))completion;

- (void)closeTwitterConnection;

- (void)verifyCredentialsWithSuccessBlock:(void (^)(NSString *))successBlock errorBlock:(void (^)(NSError *))errorBlock atIndex:(NSUInteger *)index;

- (NSString *)username;

- (BOOL) hasAccessToTwitter;

@end
