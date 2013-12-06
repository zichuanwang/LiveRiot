//
//  LRTwitterOS.m
//  LiveRiotSocial
//
//  Created by Haoyu Huang on 12/06/13.
//  Copyright (c) 2013 LiveRiot. All rights reserved.
//

#import "LRTwitterOS.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#if TARGET_OS_IPHONE
#import <Twitter/Twitter.h> // iOS 5
#endif

@interface LRTwitterOS ()
@property (nonatomic, retain) ACAccountStore *accountStore; // the ACAccountStore must be kept alive for as long as we need an ACAccount instance, see WWDC 2011 Session 124 for more info
@property (nonatomic, retain) ACAccount *account; // if nil, will be set to first account available

@property(nonatomic) BOOL twitterIOSLoggedIn;
@property(nonatomic, retain) NSString *twitterIOSAccount;

@end

@implementation LRTwitterOS

static dispatch_once_t LRTwitterOSPredicate;
static LRTwitterOS *twitterIOSEngine = nil;

+ (LRTwitterOS *)twitterIOSEngine {
    dispatch_once(&LRTwitterOSPredicate, ^{
        twitterIOSEngine = [[LRTwitterOS alloc] init];
    });
    return twitterIOSEngine;
}

- (id)init {
    self.accountStore = [[ACAccountStore alloc] init];
    self.account = nil;
    return self;
}


- (void)openTwitterIOSConnectionWithName:(NSString *)twitterAccount {
    _twitterIOSLoggedIn = YES;
    _twitterIOSAccount = twitterAccount;
    [self writeTwitterStandardUserDefaultwithLogin:_twitterIOSLoggedIn account:_twitterIOSAccount];
}

- (BOOL)isLoggedIn {
    return _twitterIOSLoggedIn;
}

- (NSString *)loggedInUserName {
    return _twitterIOSAccount;
}

- (void) closeTwitterConnection {
    if (_twitterIOSLoggedIn) {
        _twitterIOSAccount = nil;
        _twitterIOSLoggedIn = NO;
        [self writeTwitterStandardUserDefaultwithLogin:_twitterIOSLoggedIn account:_twitterIOSAccount];
    }
}

- (void)loadTwitterAccount {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _twitterIOSLoggedIn = [defaults boolForKey:@"twitteriOSloginStatus"];
    _twitterIOSAccount = [defaults stringForKey:@"twitterIOSAccount"];
}

- (void)writeTwitterStandardUserDefaultwithLogin:(bool)login account:(NSString *)account {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:account forKey:@"twitterIOSAccount"];
    [defaults setBool:login forKey:@"twitteriOSloginStatus"];
}


- (NSArray *) twitterIOSAccountswithCallback:(void (^)(NSError *))errorBlock {
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if ([self hasAccessToTwitter] == NO) {
        NSString *message = @"Cannot access Twitter account.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSCannotFindTwitterAccount userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return nil;
    }
    if(accountType == nil) {
        NSString *message = @"Cannot find Twitter account.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSCannotFindTwitterAccount userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return nil;
    }
    
    NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];

    if([accounts count] == 0) {
        NSString *message = @"No Twitter account available.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSNoTwitterAccountIsAvailable userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return nil;
    }
    return accounts;
}


- (void)showTweetSheetWithController:(UIViewController *)controller initText:(NSString *)initText completion:(void (^)(NSError *))completion
{
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                completion([NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Tweet Cancled"}]);
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone:
                completion([NSError errorWithDomain:@"" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Tweet Send"}]);
                break;
        }
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:initText];
    
    //  Presents the Tweet Sheet to the user
    [controller presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}

- (int)twitterIOSAccountSize {
    NSArray *array = [self twitterIOSAccountswithCallback:nil];
    if (array == nil) {
        return 0;
    } else {
        return [array count];
    }
}

- (NSString *)username {
    return self.account.username;
}

- (BOOL)hasAccessToTwitter {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)verifyCredentialsWithSuccessBlock:(void(^)(NSString *username))successBlock errorBlock:(void(^)(NSError *error))errorBlock atIndex:(NSUInteger *)index{
    if([self hasAccessToTwitter] == NO) {
        NSString *message = @"This system cannot access Twitter.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSSystemCannotAccessTwitter userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return;
    }
    
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    if(accountType == nil) {
        NSString *message = @"Cannot find Twitter account.";
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSCannotFindTwitterAccount userInfo:@{NSLocalizedDescriptionKey : message}];
        errorBlock(error);
        return;
    }
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                
                if(error) {
                    errorBlock(error);
                    return;
                }
                
                NSString *message = @"User denied access to their account(s).";
                NSError *grantError = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSUserDeniedAccessToTheirAccounts userInfo:@{NSLocalizedDescriptionKey : message}];
                errorBlock(grantError);
                return;
            }
            
            if(self.account == nil) {
                NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
                
                if([accounts count] == 0) {
                    NSString *message = @"No Twitter account available.";
                    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSNoTwitterAccountIsAvailable userInfo:@{NSLocalizedDescriptionKey : message}];
                    errorBlock(error);
                    return;
                } else if (*index >= [accounts count] - 1) {
                    NSString *message = @"No Twitter account available.";
                    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:STTwitterOSNoTwitterAccountIsAvailable userInfo:@{NSLocalizedDescriptionKey : message}];
                    errorBlock(error);
                    return;
                }
                self.account = [accounts objectAtIndex:*index];
            }
            
            successBlock(self.account.username);
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    [self.accountStore requestAccessToAccountsWithType:accountType
                                 withCompletionHandler:accountStoreRequestCompletionHandler];
    
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
}

@end
