//
//  LRAppDelegate.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-2.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRAppDelegate.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TMAPIClient.h"

@implementation LRAppDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  NSString *urlString = [url absoluteString];
  if ([urlString rangeOfString:@"tumblr"].location != NSNotFound) {
    return [[TMAPIClient sharedInstance] handleOpenURL:url];
  } else {
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
          [self handleAppLink:call.accessTokenData];
        }
      }
    }];
  }
}


// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppEvents activateApp];
    
    // Facebook SDK * login flow *
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActive];
}

- (void)checkSessionState:(FBSessionState)state {
    switch (state) {
        case FBSessionStateOpen:
            break;
        case FBSessionStateCreated:
            break;
        case FBSessionStateCreatedOpening:
            break;
        case FBSessionStateCreatedTokenLoaded:
            break;
        case FBSessionStateOpenTokenExtended:
            // I think this is the state that is calling
            break;
        case FBSessionStateClosed:
            break;
        case FBSessionStateClosedLoginFailed:
            break;
        default:
            break;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

@end
