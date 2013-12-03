//
//  LRFacebookShareViewController.m
//  LiveRiotSocial
//
//  Created by 王 紫川 on 13-10-11.
//  Copyright (c) 2013年 LiveRiot. All rights reserved.
//

#import "LRFacebookShareViewController.h"
#import "CRNavigationController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LRFacebookProtocols.h"

@interface LRFacebookShareViewController ()

@end

@implementation LRFacebookShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - UI

- (void)configureNavigationBar {
    [super configureNavigationBar];
    self.navigationItem.title = @"Share to Facebook";
}

#pragma mark - Action

- (void)didClickPostButton:(UIButton *)sender {
    
    if (FBSession.activeSession.isOpen) {
        // Facebook SDK * pro-tip *
        // Ask for publish permissions only at the time they are needed.
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            [self requestPermissionAndPost];
        } else {
            [self postOpenGraphAction];
        }
    } else {
        // Facebook SDK * pro-tip *
        // Support sharing even if the user isn't logged in with Facebook, by using the share dialog
        [LRFacebookShareViewController presentShareDialogForVideoInfo:self.shareLink];
    }
}

- (void)requestPermissionAndPost {
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session, NSError *error) {
                                            if (!error && [FBSession.activeSession.permissions indexOfObject:@"publish_actions"] != NSNotFound) {
                                                // Now have the permission
                                                [self postOpenGraphAction];
                                            } else if (error){
                                                // Facebook SDK * error handling *
                                                // if the operation is not user cancelled
                                                if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    [self presentAlertForError:error];
                                                }
                                            }
                                        }];
}

- (void)presentAlertForError:(NSError *)error {
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // When fberrorShouldNotifyUser is YES, a fberrorUserMessage can be
    // presented as a user-ready message
    if (error.fberrorShouldNotifyUser) {
        // The SDK has a message for the user, surface it.
        [[[UIAlertView alloc] initWithTitle:@"Something Went Wrong"
                                    message:error.fberrorUserMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"unexpected error:%@", error);
    }
}

// Creates the Open Graph Action.
- (void)postOpenGraphAction {
    
    FBRequestConnection *requestConnection = [[FBRequestConnection alloc] init];
    requestConnection.errorBehavior = FBRequestConnectionErrorBehaviorRetry | FBRequestConnectionErrorBehaviorReconnectSession;
    
    // Create an Open Graph eat action with the meal, our location, and the people we were with.
    id<LRLiveShow> video = (id<LRLiveShow>)[FBGraphObject graphObject];
    video.url = self.shareLink;
    
    id<LRWatchVideoAction> action = (id<LRWatchVideoAction>)[FBGraphObject graphObject];
    action.live_show = video;
    if (self.textView.text.length > 0)
        action.message = self.textView.text;
    [(NSMutableDictionary *)action setValue:@"true" forKey:@"fb:explicitly_shared"];
    
    // Create the request and post the action to the "me/fb_sample_scrumps:eat" path.
    FBRequest *actionRequest = [FBRequest requestForPostWithGraphPath:@"me/liveriot:share"
                                                          graphObject:action];
    
    [requestConnection addRequest:actionRequest
                completionHandler:^(FBRequestConnection *connection,
                                    id result,
                                    NSError *error) {
                    
                    if (!error) {
                        [self dismissViewControllerAnimated:YES completion:^{
                            [[[UIAlertView alloc] initWithTitle:@"Result"
                                                        message:[NSString stringWithFormat:@"Posted Open Graph action, id: %@",
                                                                 [result objectForKey:@"id"]]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil]
                             show];
                        }];
                    } else {
                        [self handlePostOpenGraphActionError:error];
                    }
                }];
    [requestConnection start];
}

- (void)handlePostOpenGraphActionError:(NSError *) error {
    // Facebook SDK * error handling *
    [self presentAlertForError:error];
}


+ (void)presentShareDialogForVideoInfo:(NSString *)shareLink {
    id liveShow = [FBGraphObject openGraphObjectForPostWithType:@"liveriot:live_show"
                                                          title:@"Amazing live music"
                                                          image:nil
                                                            url:shareLink
                                                    description:[@"Description " stringByAppendingString:@"test."]];
    
    id<LRWatchVideoAction> action = (id<LRWatchVideoAction>)[FBGraphObject graphObject];
    action.live_show = liveShow;
    
    
    [FBDialogs presentShareDialogWithOpenGraphAction:action
                                          actionType:@"liveriot:share"
                                 previewPropertyName:@"live_show"
                                             handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                 if (!error) {
                                                     NSLog(@"Results: %@", results);
                                                 } else {
                                                     NSLog(@"%@", error);
                                                     [[[UIAlertView alloc] initWithTitle:@"Failure"
                                                                                 message:[NSString stringWithFormat:@"%@", error]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"I See"
                                                                       otherButtonTitles:nil] show];
                                                 }
                                             }];
    
}

@end
